package input;

import game.actions.ActionData.ACTION_DATA;
import input.AxisSpriteCoordinates.AXIS_SPRITE_COORDINATES;
import input.ButtonSpriteCoordinates.BUTTON_SPRITE_COORDINATES;
import haxe.ds.HashMap;
import kha.Assets;
import utils.Geometry;
import kha.graphics2.Graphics;
import ui.ControlDisplay;
import game.actions.Action;
import save_data.InputSettings;
import kha.input.Gamepad;

class GamepadInputDevice extends InputDevice {
	static inline final SEPARATOR = " / ";

	public static function renderButton(g: Graphics, x: Float, y: Float, scale: Float, sprite: Geometry) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}

	final id: Int;
	final gamepad: Gamepad;

	var controlsFontHeight: Float;
	var bindingsFontHeight: Float;
	var separatorWidth: Float;

	var buttonsToActions: Map<Int, Null<Array<Action>>>;
	var axesToActions: HashMap<AxisMapping, Null<Array<Action>>>;
	var latestButtonRebindFunction: (Int, Float) -> Void;
	var latestAxisRebindFunction: (Int, Float) -> Void;

	public function new(inputSettings: InputSettings, gamepadID: Int) {
		id = gamepadID;
		gamepad = Gamepad.get(gamepadID);

		super(GAMEPAD, inputSettings);
	}

	function buttonListener(button: Int, value: Float) {
		if (value != 0)
			AnyInputDevice.lastGamepadID = id;

		if (!buttonsToActions.exists(button))
			return;

		final actions = buttonsToActions[button];

		if (value == 0) {
			upListener(actions);
		} else {
			buttonDownListener(actions);
		}
	}

	function buttonDownListener(actions: Array<Action>) {
		for (action in actions) {
			counters[action] = 0;
		}
	}

	function upListener(actions: Array<Action>) {
		for (action in actions) {
			counters.remove(action);
		}
	}

	function axisListener(axis: Int, value: Float) {
		for (k => v in axesToActions.keyValueIterator()) {
			// Easy matching using multiplication
			// -1 * -1 => 1
			// 1 * 1 => 1
			// If the direction and value signs match, the result is positive
			if (k.axis == axis && k.direction * value >= 0) {
				if (Math.abs(value) > inputSettings.deadzone) {
					axisDownListener(v);
				} else {
					upListener(v);
				}

				// Clear actions assigned to the inverse direction. With
				// properly configured deadzone, this prevents stick "rebound"
				// and drifting.
				final oppositeMapping: AxisMapping = {axis: axis, direction: k.direction * -1};

				if (axesToActions.exists(oppositeMapping)) {
					upListener(axesToActions[oppositeMapping]);
				}

				return;
			}
		}
	}

	function axisDownListener(actions: Array<Action>) {
		for (action in actions) {
			if (counters.exists(action))
				continue;

			counters[action] = 0;
		}
	}

	function buttonRebindListener(action: Action, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputSettings.mappings[action];

		inputSettings.mappings[action] = ({
			keyboardInput: original.keyboardInput,
			gamepadButton: button,
			gamepadAxis: original.gamepadAxis
		} : InputMapping);

		finishRebind();
	}

	function axisRebindListener(action: Action, axis: Int, value: Float) {
		if (value <= inputSettings.deadzone && value >= -inputSettings.deadzone)
			return;

		final original = inputSettings.mappings[action];

		inputSettings.mappings[action] = ({
			keyboardInput: original.keyboardInput,
			gamepadButton: original.gamepadButton,
			gamepadAxis: {axis: axis, direction: (value > 0) ? 1 : -1}
		} : InputMapping);

		finishRebind();
	}

	override function buildActions() {
		actions = [];
		buttonsToActions = [];
		axesToActions = new HashMap();

		for (action in ACTION_DATA.keys()) {
			final mapping = inputSettings.mappings[action];

			final buttonInput = mapping.gamepadButton;

			if (buttonsToActions[buttonInput] == null)
				buttonsToActions[buttonInput] = [];

			buttonsToActions[buttonInput].push(action);

			final axisMapping = mapping.gamepadAxis;

			if (axisMapping != null) {
				if (axesToActions[axisMapping] == null)
					axesToActions[axisMapping] = [];

				axesToActions[axisMapping].push(action);
			}

			switch (ACTION_DATA[action].inputType) {
				case HOLD:
					actions[action] = holdActionHandler;
				case PRESS:
					actions[action] = pressActionHandler;
				case REPEAT:
					actions[action] = repeatActionHandler;
			}
		}
	}

	override function addListeners() {
		try {
			gamepad.notify(axisListener, buttonListener);
		}
	}

	override function removeListeners() {
		try {
			gamepad.remove(axisListener, buttonListener);
		}
	}

	override function removeRebindListeners() {
		try {
			gamepad.remove(latestAxisRebindFunction, latestButtonRebindFunction);
		}
	}

	override function rebind(action: Action) {
		super.rebind(action);

		latestAxisRebindFunction = axisRebindListener.bind(action);
		latestButtonRebindFunction = buttonRebindListener.bind(action);
		latestRebindAction = action;

		try {
			gamepad.notify(latestAxisRebindFunction, latestButtonRebindFunction);
		}
	}

	override function renderBinding(g: Graphics, x: Float, y: Float, action: Action) {
		super.renderBinding(g, x, y, action);

		final title = ACTION_DATA[action].title;

		if (action == latestRebindAction && isRebinding) {
			g.drawString('Press any button / stick for [ $title ]', x, y);

			return;
		}

		final str = '$title: ';
		final strW = g.font.width(g.fontSize, str);
		final mapping = inputSettings.mappings[action];
		final buttonSpr = BUTTON_SPRITE_COORDINATES[mapping.gamepadButton];

		g.drawString(str, x, y);
		x += strW;

		g.color = White;

		renderButton(g, x, y, bindingsFontHeight / buttonSpr.height, buttonSpr);

		final axisMapping = mapping.gamepadAxis;

		if (axisMapping == null)
			return;

		x += buttonSpr.width * ScaleManager.smallerScale;

		g.drawString(SEPARATOR, x, y);
		x += separatorWidth;

		final axisSpr = AXIS_SPRITE_COORDINATES[mapping.gamepadAxis.hashCode()];

		renderButton(g, x, y, bindingsFontHeight / axisSpr.height, axisSpr);
	}

	override function renderControls(g: Graphics, x: Float, y: Float, controls: Array<ControlDisplay>) {
		super.renderControls(g, x, y, controls);

		for (d in controls) {
			var str = "";

			for (action in d.actions) {
				final mapping = inputSettings.mappings[action];
				final buttonSpr = BUTTON_SPRITE_COORDINATES[mapping.gamepadButton];

				renderButton(g, x, y, controlsFontHeight / buttonSpr.height, buttonSpr);
				x += buttonSpr.width * ScaleManager.smallerScale;

				if (mapping.gamepadAxis == null)
					continue;

				final axisSpr = AXIS_SPRITE_COORDINATES[mapping.gamepadAxis.hashCode()];

				renderButton(g, x, y, controlsFontHeight / axisSpr.height, axisSpr);
				x += axisSpr.width * ScaleManager.smallerScale;
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';

			final strWidth = g.font.width(g.fontSize, str);

			g.drawString(str, x, y);

			x += strWidth;
		}
	}
}
