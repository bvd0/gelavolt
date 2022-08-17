package game.actionbuffers;

import game.net.SessionManager;
import game.actionbuffers.LocalActionBuffer.LocalActionBufferOptions;

@:structInit
@:build(game.Macros.buildOptionsClass(SenderActionBuffer))
class SenderActionBufferOptions extends LocalActionBufferOptions {}

class SenderActionBuffer extends LocalActionBuffer {
	@inject final session: SessionManager;

	public function new(opts: SenderActionBufferOptions) {
		super(opts);

		Macros.initFromOpts();
	}

	override function update(): Null<ActionSnapshot> {
		final latestAction = super.update();

		session.sendInput(frameCounter.value + frameDelay, latestAction.toBitField());

		return latestAction;
	}

	override function activate() {
		super.activate();
		session.isInputIdle = false;
	}

	override function deactivate() {
		super.deactivate();
		session.isInputIdle = true;
	}
}
