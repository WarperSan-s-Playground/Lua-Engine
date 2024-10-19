package helpers;

import flixel.system.debug.log.LogStyle;

/** Handles logging given values */
class LogHelper
{
	private static var VERBOSE:LogStyle = new LogStyle("[VERBOSE] ", "AAAAAA");

	/**
	 * Logs the given value with the given level
	 * @param value Value to log
	 * @param level Level to log at
	 */
	private static function log(value:Dynamic, level:LogStyle):Void
	{
		value = Std.string(value);

		// Choose prefix
		var prefix:String = "";

		if (level == LogStyle.CONSOLE)
			prefix = "[DEBUG] ";
		else
			prefix = level.prefix;

		// Choose postfix
		var postfix:String = "";

		if (level == VERBOSE)
		{
			var now = Date.now();
			var hours = StringTools.lpad(Std.string(now.getHours()), "0", 2);
			var minutes = StringTools.lpad(Std.string(now.getMinutes()), "0", 2);
			var seconds = StringTools.lpad(Std.string(now.getSeconds()), "0", 2);
			var milliseconds = StringTools.lpad(Std.string(Math.floor(now.getTime() % 1000)), "0", 3);

			postfix = ' ($hours:$minutes:$seconds.$milliseconds)';
		}

		// Print value
		Sys.println(prefix + value + postfix);

		// Limit verbose to output console
		if (level != VERBOSE)
			flixel.FlxG.log.advanced(value, level);
	}

	/**
	 * Logs the given value as an error
	 * @param value Value to log
	 */
	public static function error(value:Dynamic):Void
	{
		log(value, LogStyle.ERROR);
	}

	/**
	 * Logs the given value as a warning
	 * @param value Value to log
	 */
	public static function warn(value:Dynamic):Void
	{
		log(value, LogStyle.WARNING);
	}

	/**
	 * Logs the given value as a debug
	 * @param value Value to log
	 */
	public static function debug(value:Dynamic):Void
	{
		log(value, LogStyle.CONSOLE);
	}

	/**
	 * Logs the given value as a verbose
	 * @param value Value to log 
	 */
	public static function verbose(value:Dynamic):Void
	{
		log(value, VERBOSE);
	}

	/**
	 * Logs the given value as a notice
	 * @param value Value to log
	 */
	public static function info(value:Dynamic):Void
	{
		log(value, LogStyle.NOTICE);
	}
}
