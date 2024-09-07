package builtin;

import lua_bridge.LuaCache;
import lua_bridge.LuaScript;
import haxe.Json;
import haxe.io.Path;
import helpers.FileHelper;

/** Class holding every built-in methods for files */
class FileBuiltIn
{
	/**
	 * Parses the given file as JSON
	 * @param file File to parse
	 * @return Object created
	 */
	public static function fromJSON(file:Null<String> = null):Dynamic
	{
		var fixed:String = FileHelper.GetPath(file);

		// File not found
		if (fixed == null)
			throw('Could not find a file at \'$file\'.');

		// Check for extension
		var extension:Null<String> = Path.extension(fixed);
		if (extension != "json")
			throw('Expected a JSON file. Received a \'$extension\' file.');

		// Read content
		var content:String = FileHelper.ReadFile(fixed);
		if (content == null)
			throw('Failed to load the file \'$fixed\'.');

		return Json.parse(content);
	}

	/**
	 * Opens a script with the given file
	 * @param file File to open
	 * @param isRelated Is the file related to the current script?
	 */
	public static function addScript(file:Null<String> = null, isRelated:Bool = true):Void
	{
		var fixed:String = FileHelper.GetPath(file);

		// File not found
		if (fixed == null)
			throw('Could not find a file at \'$file\'.');

		// Check for extension
		var extension:Null<String> = Path.extension(fixed);
		if (extension != "lua")
			throw('Expected a LUA file. Received a \'$extension\' file.');

		var child:Null<LuaScript> = null;

		// Create the script as child
		if (isRelated)
		{
			var script:Null<LuaScript> = LuaCache.GetScript();

			if (script == null)
				throw('Tried to add a script from an invalid script.');

			child = script.openOther(file);
		}
        else
            child = LuaScript.openFile(file);

		if (child == null)
			throw('Failed to create a script for the file \'$file\'.');
	}
}
