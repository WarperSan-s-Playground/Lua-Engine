package builtin;

import haxe.PosInfos;
import helpers.LogHelper;

/**
 * Class holding every built-in methods for logs
 */
class LogBuiltIn
{
	/**
	 * Prints a value to the debug console and in-game log
	 * @param value Value to print
	 */
	public static function trace(value:Dynamic, ?infos:Null<PosInfos>):Void
	{
		LogHelper.info(value);
	}
}
