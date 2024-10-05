package builtin;

import helpers.LogHelper;

/** Class holding every built-in methods for logs */
@:rtti
class LogBuiltIn
{
	/**
	 * Prints a value to the debug console and in-game log
	 * @param value Value to print
	 */
	public static function trace(value:Dynamic):Void
	{
		LogHelper.info(value);
	}
}
