package helpers;

import haxe.ds.StringMap;
import engine.ScriptCache;

class ClassHelper
{
	private static var cachedTypes:StringMap<Null<Class<Dynamic>>> = new StringMap<Null<Class<Dynamic>>>();

	/**
	 * Fetches the class at the given path 
	 * @param path Path to the class
	 * @return Class found
	 */
	public static function getClassFromPath(path:String):Dynamic
	{
		var id:Null<Int> = findID(path);
		var type:Null<Dynamic> = findType(path);
		var field:Null<String> = findField(path);

		if (type == null || field == null)
			throw('The path \'$path\' is not valid.');

		var obj:Null<Dynamic> = null;

		// ID
		if (id != null)
		{
			if (type == null)
				type = "flixel.FlxBasic";

			obj = FlxBasicHelper.getObject(id, type);
		}
		// TYPE
		else if (type != null)
		{
			obj = type;
		}

		return {
			obj: obj,
			field: field
		};
	}

	/**
	 * Fetches the value of the field at the given path from the given class
	 * @param obj Class to fetch from
	 * @param path Path to the field
	 * @return Field found
	 */
	public static function getClassField(obj:Dynamic, path:String):Null<Dynamic>
	{
		var current:Dynamic = obj;
		var counter:Int = 0;
		var segments:Array<String> = path.split('.');

		for (i in segments)
		{
			if (current == null)
				throw('Could not continue the search from \'$path\', because \'${segments[counter - 1]}\' is null.');

			current = Reflect.getProperty(current, i);
			counter++;
		}

		return current;
	}

	/**
	 * Fetches the class from the given name
	 * @param name Full name of the class
	 * @return Null<Class<Dynamic>> Class found
	 */
	public static function getClassFromName(name:String):Null<Class<Dynamic>>
	{
		// If type cached, skip
		if (cachedTypes.exists(name))
			return cachedTypes.get(name);

		var type:Null<Class<Dynamic>> = Type.resolveClass(name);

		cachedTypes.set(name, type);
		return type;
	}

	// #region ID
	private static var ID_REGEX:EReg = ~/(?<={)\d*(?=}:)/g;

	/** Tries to find the ID in the given path */
	private static function findID(path:String):Null<Int>
	{
		if (!ID_REGEX.match(path))
			return null;

		var s:String = ID_REGEX.matched(0); // Get value found
		return Std.parseInt(s);
	}

	// #endregion
	// #region Type
	private static var TYPE_REGEX:EReg = ~/^.*?(?=[{|:])/g;

	/** Tries to find the type in the given path */
	private static function findType(path:String):Null<Dynamic>
	{
		if (!TYPE_REGEX.match(path))
			return ScriptCache.GetScript();

		var s:String = TYPE_REGEX.matched(0); // Get value found
		return getClassFromName(s);
	}

	// #endregion
	// #region Field
	private static var FIELD_REGEX:EReg = ~/(?<=:).*$/g;

	/** Tries to find the field in the given path */
	private static function findField(path:String):Null<String>
	{
		if (!FIELD_REGEX.match(path))
			return null;

		return FIELD_REGEX.matched(0); // Get value found
	}

	// #endregion
}
