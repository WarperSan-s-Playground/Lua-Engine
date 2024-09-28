package helpers;

import flixel.util.FlxColor;
import lua_bridge.LuaCache;

class ClassHelper
{
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

			obj = LuaHelper.getObject(parsedPath.id, parsedPath.type);
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

			// Stop when reaching the field
			current = Reflect.field(current, i);
			counter++;
		}

		return current;
	}

	private static function parsePath(path:String):Dynamic
	{
		// Find ID
		var idRegex = ~/{\d*}/g;
		var id:Null<Int> = null;

		if (idRegex.match(path))
		{
			var s:String = idRegex.matched(0);
			id = Std.parseInt(s.substring(1, s.length - 1));
			path = path.split(s).join("");
		}

		// Find type
		var typeRegex:EReg = ~/.*:/g;
		var type:Null<Dynamic> = null;

		if (typeRegex.match(path))
		{
			var s:String = typeRegex.matched(0);
			type = Type.resolveClass(s.substr(0, s.length - 1));
			path = path.split(s).join("");
		}
		else
			type = LuaCache.GetScript();

		return {
			type: type,
			id: id,
			path: path
		};
	}
}
