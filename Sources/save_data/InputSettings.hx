package save_data;

import input.AxisSpriteCoordinates.AXIS_SPRITE_COORDINATES;
import input.ButtonSpriteCoordinates.BUTTON_SPRITE_COORDINATES;
import input.GamepadBrand;
import haxe.ds.StringMap;
import game.actions.Action;
import input.InputMapping;

enum abstract InputSettingsKey(String) to String {
	final MAPPINGS;
	final DEADZONE;
	final GAMEPAD_BRAND;
	final LOCAL_DELAY;
	final NETPLAY_DELAY;
}

class InputSettings {
	public static final MAPPINGS_DEFAULTS: Map<Action, InputMapping> = [
		PAUSE => {
			keyboardInput: Escape,
			gamepadButton: OPTIONS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		MENU_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {axis: 0, direction: -1}
		},
		MENU_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {axis: 0, direction: 1}
		},
		MENU_DOWN => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {axis: 1, direction: 1},
		},
		MENU_UP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {axis: 1, direction: -1}
		},
		BACK => {
			keyboardInput: Backspace,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		CONFIRM => {
			keyboardInput: Return,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		SHIFT_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {
				axis: 0,
				direction: -1
			}
		},
		SHIFT_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {
				axis: 0,
				direction: 1
			}
		},
		SOFT_DROP => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {
				axis: 1,
				direction: 1
			}
		},
		HARD_DROP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {
				axis: 1,
				direction: -1
			}
		},
		ROTATE_LEFT => {
			keyboardInput: D,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		ROTATE_RIGHT => {
			keyboardInput: F,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		TOGGLE_EDIT_MODE => {
			keyboardInput: Q,
			gamepadButton: SHARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		EDIT_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {axis: 0, direction: -1}
		},
		EDIT_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {axis: 0, direction: 1}
		},
		EDIT_DOWN => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {axis: 1, direction: 1},
		},
		EDIT_UP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {axis: 1, direction: -1}
		},
		EDIT_CLEAR => {
			keyboardInput: D,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		EDIT_SET => {
			keyboardInput: F,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_STEP => {
			keyboardInput: Y,
			gamepadButton: SQUARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_STEP => {
			keyboardInput: X,
			gamepadButton: TRIANGLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_COLOR => {
			keyboardInput: C,
			gamepadButton: L2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_COLOR => {
			keyboardInput: V,
			gamepadButton: R2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_GROUP => {
			keyboardInput: Y,
			gamepadButton: SQUARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_GROUP => {
			keyboardInput: X,
			gamepadButton: TRIANGLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		TOGGLE_MARKERS => {
			keyboardInput: B,
			gamepadButton: R1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		QUICK_RESTART => {
			keyboardInput: R,
			gamepadButton: L1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		SAVE_STATE => {
			keyboardInput: O,
			gamepadButton: R1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		LOAD_STATE => {
			keyboardInput: P,
			gamepadButton: R2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		}
	];

	static inline final DEADZONE_DEFAULT = 0.5;
	static inline final GAMEPAD_BRAND_DEFAULT = GamepadBrand.DS4;
	static inline final LOCAL_DELAY_DEFAULT = 0;
	static inline final NETPLAY_DELAY_DEFAULT = 2;

	final updateListeners: Array<Void->Void>;

	public var mappings(default, null): Map<Action, InputMapping>;
	public var deadzone: Float;
	public var gamepadBrand: GamepadBrand;
	public var localDelay: Int;
	public var netplayDelay: Int;

	public function new(overrides: Map<InputSettingsKey, Any>) {
		updateListeners = [];

		setDefaults();

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, InputSettingsKey)) {
						case MAPPINGS:
							for (kk => vv in cast(v, Map<Dynamic, Dynamic>)) {
								mappings[cast(kk, Action)] = InputMapping.fromString(cast(vv, String));
							}
						case DEADZONE:
							deadzone = cast(v, Float);
						case GAMEPAD_BRAND:
							gamepadBrand = cast(v, GamepadBrand);
						case LOCAL_DELAY:
							localDelay = cast(v, Int);
						case NETPLAY_DELAY:
							netplayDelay = cast(v, Int);
					}
				} catch (_) {
					continue;
				}
			}
		} catch (_) {}
	}

	public function exportOverrides() {
		final overrides = new StringMap<Any>();
		var wereOverrides = false;

		final mappingOverrides = new Map<Action, String>();
		var wereMappingOverrides = false;

		for (k => v in mappings) {
			if (v.isNotEqual(MAPPINGS_DEFAULTS[k])) {
				mappingOverrides.set(k, v.asString());
				wereMappingOverrides = true;
			}
		}

		if (wereMappingOverrides) {
			overrides.set(MAPPINGS, mappingOverrides);
			wereOverrides = true;
		}

		if (deadzone != DEADZONE_DEFAULT) {
			overrides.set(DEADZONE, deadzone);
			wereOverrides = true;
		}

		if (gamepadBrand != GAMEPAD_BRAND_DEFAULT) {
			overrides.set(GAMEPAD_BRAND, gamepadBrand);
			wereOverrides = true;
		}

		if (localDelay != LOCAL_DELAY_DEFAULT) {
			overrides.set(LOCAL_DELAY, localDelay);
			wereOverrides = true;
		}

		if (netplayDelay != NETPLAY_DELAY_DEFAULT) {
			overrides.set(NETPLAY_DELAY, netplayDelay);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}

	public function addUpdateListener(callback: Void->Void) {
		updateListeners.push(callback);

		callback();
	}

	public function notifyListeners() {
		for (f in updateListeners) {
			f();
		}
	}

	public function setDefaults() {
		mappings = MAPPINGS_DEFAULTS.copy();

		deadzone = DEADZONE_DEFAULT;
		gamepadBrand = GAMEPAD_BRAND_DEFAULT;
		localDelay = LOCAL_DELAY_DEFAULT;
		netplayDelay = NETPLAY_DELAY_DEFAULT;

		notifyListeners();
	}

	public function getButtonSprite(action: Action) {
		return BUTTON_SPRITE_COORDINATES[gamepadBrand][mappings[action].gamepadButton];
	}

	public function getAxisSprite(action: Action) {
		return AXIS_SPRITE_COORDINATES[gamepadBrand][mappings[action].gamepadAxis.hashCode()];
	}
}
