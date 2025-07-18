package utilities;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

enum abstract Action(String) to String from String {
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}

enum Device {
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control {
	UP;
	LEFT;
	RIGHT;
	DOWN;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
}

enum KeyboardScheme {
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet {
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);

	var byName:Map<String, FlxActionDigital> = [];

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	public function new(name, scheme = None) {
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}

	// inline
	public function checkByName(name:Action):Bool {
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String {
		var input = action.inputs[0];
		return switch input.device {
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String {
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital {
		return switch (control) {
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
		}
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void) {
		switch (control) {
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int) {
		if (toAdd == toRemove)
			return;

		switch (device) {
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device) {
		for (name => action in controls.byName) {
			for (input in action.inputs) {
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}

		switch (device) {
			case null:
				// add all
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device) {
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void {
		if (scheme != None) {
			switch (keyboardScheme) {
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>) {
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>) {
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState) {
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>) {
		var i = action.inputs.length;
		while (i-- > 0) {
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true) {
		loadKeyBinds();
	}

	// thanks kade engine, cuz idk how to make this stuff lol
	public function loadKeyBinds() {
		removeKeyboard();

		inline bindKeys(Control.UP, [FlxKey.W, FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.S, FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.A, FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.D, FlxKey.RIGHT]);
		inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
		inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
		inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
		inline bindKeys(Control.RESET, [FlxKey.fromString(Options.getData("kill", "binds"))]);
	}

	function removeKeyboard() {
		for (action in this.digitalActions) {
			var i = action.inputs.length;
			while (i-- > 0) {
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void {
		gamepadsAdded.push(id);

		for (control => buttons in buttonMap)
		inline bindButtons(control, id, buttons);
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void {
		gamepadsAdded.push(id);

		for (control => buttons in buttonMap)
		inline bindButtons(control, id, buttons);
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void {
		for (action in this.digitalActions) {
			var i = action.inputs.length;
			while (i-- > 0) {
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void {
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public inline function bindButtons(control:Control, id, buttons) {
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public inline function unbindButtons(control:Control, gamepadID:Int, buttons) {
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id) {
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>) {
		var i = action.inputs.length;
		while (i-- > 0) {
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int> {
		if (list == null)
			list = [];

		switch (device) {
			case Keys:
				for (input in getActionFromControl(control).inputs) {
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs) {
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device) {
		switch (device) {
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device) {
		return switch device {
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int) {
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
