package helpers;

import haxe.ds.StringMap;
import engine.ScriptCache;

class ClassHelper
{
	private static var ID_REGEX:EReg = ~/{\d*}/g;
	private static var TYPE_REGEX:EReg = ~/.*:/g;

	private static var cachedTypes:StringMap<Null<Class<Dynamic>>> = new StringMap<Null<Class<Dynamic>>>();

	/**
	 * Fetches the class at the given path 
	 * @param path Path to the class
	 * @return Class found
	 */
	public static function getClassFromPath(path:Null<String>):Dynamic
	{
		// If not defined, skip
		if (path == null)
			throw('No path was defined.');

		var obj:Null<Dynamic> = null;

		// TYPE{ID}:PATH
		var parsedPath:Dynamic = parsePath(path);

		// ID + Path
		if (parsedPath.id != null)
		{
			if (parsedPath.type == null)
				parsedPath.type = "flixel.FlxBasic";

			obj = FlxBasicHelper.getObject(parsedPath.id, parsedPath.type);
		}
		// PATH + TYPE
		else if (parsedPath.path != null && parsedPath.type != null)
		{
			obj = parsedPath.type;
		}

		return {
			obj: obj,
			path: parsedPath.path
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

			// Stop when reaching the property
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

	private static function parsePath(path:String):Dynamic
	{
		// Find ID
		var id:Null<Int> = null;

		if (ID_REGEX.match(path))
		{
			var s:String = ID_REGEX.matched(0);
			id = Std.parseInt(s.substring(1, s.length - 1));
			path = path.split(s).join("");
		}

		// Find type
		var type:Null<Dynamic> = null;

		if (TYPE_REGEX.match(path))
		{
			var s:String = TYPE_REGEX.matched(0);
			type = getClassFromName(s.substr(0, s.length - 1));
			path = path.split(s).join("");
		}
		else
			type = ScriptCache.GetScript();

		return {
			type: type,
			id: id,
			path: path
		};
	}
}
