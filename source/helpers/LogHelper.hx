package helpers;

import flixel.system.debug.log.LogStyle;

class LogHelper
{
	/**
	 * Logs the given value with the given level
	 * @param value Value to log
	 * @param level Level to log at
	 */
	private static function log(value:Dynamic, level:LogStyle):Void
	{
		if (value == null)
			value = "null";

		Sys.println(value);
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
	 * Logs the given value as a notice
	 * @param value Value to log
	 */
	public static function info(value:Dynamic):Void
	{
		log(value, LogStyle.NOTICE);
	}
}
