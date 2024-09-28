package helpers;

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

		// Get variable from basic '{0}:test'
		if (path.indexOf('{') != -1 && path.indexOf('}:') != -1)
		{
			var id:Null<Int> = Std.parseInt(path.split('{')[1].split('}:')[0]);

			if (id == null)
				throw('The given ID of \'$id\' is not valid.');

			obj = LuaHelper.getObject(id);
		}
		// Get class of path 'flixel.FlxG:width'
		else if (path.indexOf(':') != -1)
		{
			var className:String = path.split(':')[0];
			path = path.substr(className.length + 1);
			obj = Type.resolveClass(className);

			if (obj == null)
				throw('Could not find the class named \'$className\'.');
		}
		// Get variable from local script 'file'
		else
		{
			obj = LuaCache.GetScript();

			if (obj == null)
				throw('No script was run before this.');
		}

		return {
			obj: obj,
			path: path
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
				throw('Could not continue the search, because \'${segments[counter - 1]}\' is null.');

			// Stop when reaching the field
			current = Reflect.field(current, i);
			counter++;
		}

		return current;
	}
}
