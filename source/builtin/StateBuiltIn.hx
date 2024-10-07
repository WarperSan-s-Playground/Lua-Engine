package builtin;

import flixel.FlxG;
import helpers.FileHelper;
import states.ScriptState;

/** Class holding every built-in methods for states */
@:rtti
class StateBuiltIn
{
	/**
	 * Switches to a new state powered by the given file
	 * @param file File that manages the new state
	 */
	public static function switchState(file:Null<String> = null):Void
	{
		// Get path
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Tried to create a state from a missing file.');

		// Create state
		var state:ScriptState = new ScriptState(file);

		// Switch state
		FlxG.switchState(state);
	}
}
