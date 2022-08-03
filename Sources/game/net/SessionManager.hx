package game.net;

import game.net.PacketType;
import game.net.ServerMessageType;
import game.mediators.FrameCounter;
import haxe.Timer;
import haxe.io.Bytes;
import kha.Scheduler;
import haxe.net.WebSocket;

@:structInit
@:build(game.Macros.buildOptionsClass(SessionManager))
class SessionManagerOptions {}

class SessionManager {
	@inject final serverUrl: String;
	@inject final roomCode: String;

	final frameCounter: FrameCounter;

	var ws: WebSocket;

	var syncTimeTaskID: Int;
	var roundTripCounter: Int;
	var localAdvantageCounter: Int;
	var remoteAdvantageCounter: Int;

	var sleepFrames: Int;
	var internalSleepCounter: Int;

	var beginFrame: Null<Int>;

	public var onInput(null, default): (Int, Int) -> Void;
	public var isInputIdle(null, default): Bool;

	public var averageRTT(default, null): Null<Int>;
	public var averageLocalAdvantage(default, null): Null<Int>;
	public var averageRemoteAdvantage(default, null): Null<Int>;
	public var successfulSleepChecks(default, null): Null<Int>;
	public var state(default, null): SessionState;

	public function new(opts: SessionManagerOptions) {
		Macros.initFromOpts();

		frameCounter = new FrameCounter();

		initConnectingState();
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function onClose(?e: Null<Dynamic>) {
		trace('WS Closed: $e');
	}

	function onServerMessage(msg: Bytes) {
		switch ((msg.get(0) : ServerMessageType)) {
			case BEGIN_SYNC:
				initSyncingState();
		}
	}

	function onMessage(msg: String) {
		final parts = msg.split(";");

		final type: PacketType = Std.parseInt(parts[0]);

		switch (type) {
			case SYNC_REQ:
				onSyncRequest(parts);
			case SYNC_RESP:
				onSyncResponse(parts);
			case INPUT:
				onInputPacket(parts);
			case BEGIN_REQ:
				onBeginRequest(parts);
			case BEGIN_RESP:
				onBeginResponse(parts);
		}
	}

	function onError(msg: String) {
		trace('WS Error: $msg');
	}

	function initConnectingState() {
		ws = WebSocket.create("ws://" + serverUrl + "/" + roomCode);

		ws.onopen = initWaitingState;
		ws.onclose = onClose;
		ws.onmessageBytes = onServerMessage;
		ws.onmessageString = onMessage;
		ws.onerror = onError;

		#if sys
		Scheduler.addTimeTask(ws.process, 0, 0.0001);
		#end

		state = CONNECTING;
	}

	function initWaitingState() {
		state = WAITING;
	}

	function initSyncingState() {
		roundTripCounter = 0;
		localAdvantageCounter = 0;
		remoteAdvantageCounter = 0;

		sleepFrames = 0;
		internalSleepCounter = 0;

		setSyncInterval(100);

		isInputIdle = true;

		state = SYNCING;
	}

	function sendSyncRequest() {
		final ping = Std.int(Timer.stamp() * 1000);

		var prediction: Null<Int> = null;

		if (averageRTT != null) {
			prediction = frameCounter.value + Std.int(averageRTT / 2 * 60 / 1000);
		}

		ws.sendString('$SYNC_REQ;$ping;$prediction');
	}

	function onSyncRequest(parts: Array<String>) {
		final pong = parts[1];
		final prediction = Std.parseInt(parts[2]);

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - prediction;

			averageLocalAdvantage = Math.round(0.4 * adv + 0.6 * averageLocalAdvantage);
		}

		ws.sendString('$SYNC_RESP;$pong;$adv');
	}

	function onSyncResponse(parts: Array<String>) {
		final pong = Std.parseInt(parts[1]);
		final rtt = Std.int(Timer.stamp() * 1000) - pong;

		averageRTT = Math.round(0.7 * rtt + 0.3 * averageRTT);

		final adv = Std.parseInt(parts[2]);

		if (adv != null) {
			averageRemoteAdvantage = Math.round(0.4 * adv + 0.6 * averageRemoteAdvantage);

			if (internalSleepCounter == 0 && ++remoteAdvantageCounter % 5 == 0) {
				final diff = averageLocalAdvantage - averageRemoteAdvantage;

				if (Math.abs(diff) < 4) {
					if (++successfulSleepChecks > 10) {
						initBeginningState();

						return;
					}
				} else {
					successfulSleepChecks = 0;
				}

				if (averageLocalAdvantage < averageRemoteAdvantage) {
					sleepFrames = 0;
					internalSleepCounter = 0;
					return;
				}

				final diff = averageLocalAdvantage - averageRemoteAdvantage;
				final s = Math.round(diff / 2);

				if (s < 2) {
					sleepFrames = 0;
					internalSleepCounter = 0;
					return;
				}

				sleepFrames = s;
				internalSleepCounter = s;
			}
		}
	}

	function initBeginningState() {
		ws.sendString('$BEGIN_REQ');

		state = BEGINNING;
	}

	function onBeginRequest(parts: Array<String>) {
		ws.sendString('$BEGIN_RESP;$beginFrame');
	}

	function onBeginResponse(parts: Array<String>) {
		beginFrame = Std.parseInt(parts[1]);

		if (beginFrame == null) {
			beginFrame = frameCounter.value + Std.int(averageRTT * 10);
		}
	}

	function onInputPacket(parts: Array<String>) {
		final frame = Std.parseInt(parts[1]);
		final actions = Std.parseInt(parts[2]);

		onInput(frame, actions);
	}

	function initRunningState() {
		setSyncInterval(500);

		state = RUNNING;
	}

	function updateSyncingState() {
		if (internalSleepCounter > 0) {
			internalSleepCounter--;
			return 0;
		}

		frameCounter.update();

		return 0;
	}

	function updateBeginningState() {
		if (frameCounter.value == beginFrame) {
			setSyncInterval(1000);

			state = RUNNING;

			return 0;
		}

		frameCounter.update();

		return 0;
	}

	function updateRunningState() {
		if (isInputIdle) {
			final s = Std.int(Math.min(sleepFrames, 9));

			sleepFrames = 0;

			return s;
		}

		return 0;
	}

	public function setSyncInterval(interval: Int) {
		Scheduler.removeTimeTask(syncTimeTaskID);

		syncTimeTaskID = Scheduler.addTimeTask(sendSyncRequest, 0, interval / 1000);
	}

	public inline function sendInput(frame: Int, actions: Int) {
		ws.sendString('$INPUT;$frame;$actions');
	}

	public function update() {
		return switch (state) {
			case SYNCING: updateSyncingState();
			case BEGINNING: updateBeginningState();
			case RUNNING: updateRunningState();
			default: 0;
		}
	}
}
