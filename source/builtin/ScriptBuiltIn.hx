package builtin;

import lua_bridge.LuaImport;
import helpers.LogHelper;
import lua_bridge.LuaCache;
import haxe.io.Path;
import helpers.FileHelper;
import lua_bridge.LuaParenting;
import lua_bridge.LuaScript;

/** Class holding every built-in methods for scripts */
@:rtti
class ScriptBuiltIn
{
	/**
	 * Opens a script with the given file
	 * @param file File to open
	 * @param autoImport Automatically imports all the built-in methods
	 * @param isRelated Is the file related to the current script?
	 */
	public static function addScript(file:Null<String> = null, autoImport:Bool = true, isRelated:Bool = true):Null<Dynamic>
	{
		var fixed:String = FileHelper.GetPath(file);

		// File not found
		if (fixed == null)
			throw('Could not find a file at \'$file\'.');

		// Check for extension
		var extension:Null<String> = Path.extension(fixed);
		if (extension != "lua")
			throw('Expected a LUA file. Received a \'$extension\' file.');

		var createResult = null;

		// Create the script as child
		if (isRelated)
		{
			var script:Null<LuaScript> = LuaCache.GetScript();

			if (script == null)
				throw('Tried to add a script from an invalid script.');

			createResult = script.openOther(file, autoImport);
		}
		else
			createResult = LuaScript.openFile(file, autoImport);

		var child:Null<LuaScript> = createResult.first;

		if (child == null)
			throw('Failed to create a script for the file \'$file\'.');

		var results:Map<String, Null<Dynamic>> = createResult.second;

		// If empty, null
		if (!results.keys().hasNext())
			return null;

		// Get first value
		var value:Null<Dynamic> = results.get(results.keys().next());

		if (value == null)
			return null;
		return value.value;
	}

	/**
	 * Closes the script associated with the given file
	 * @param file File to close
	 */
	public static function closeScript(file:Null<String> = null):Void
	{
		// If file not given, skip
		if (file == null)
			return;

		var script:Null<LuaScript> = LuaParenting.Find(file);

		if (script == null)
			throw('Could not find an instance of \'$file\'.');

		script.close();
	}

	/**
	 * Imports the given file to this script
	 * @param file File to import
	 */
	public static function importFile(file:Null<String> = null):Void
	{
		// If invalid
		if (file == null)
			throw('No file was given to import.');

		var script:Null<LuaScript> = LuaCache.GetScript();

		if (script == null)
			throw('Tried to import a file to an invalid script.');

		var targetFile:Null<Dynamic> = null;

		for (_file in LuaImport.IMPORTABLE_BUILT_IN)
		{
			var name:Null<String> = Type.getClassName(_file).split('.').pop();

			if (name == null)
				continue;

			// If the target file is this file
			if (name == file)
			{
				targetFile = _file;
				break;
			}

			// If the target file is miswritten (SHORTEN)
			if (name == file + "BuiltIn")
			{
				LogHelper.warn('Please import the file as \'$name\' instead of \'$file\'.');
				targetFile = _file;
				break;
			}

			// If the target file is miswritten (CASE INSENSITIVE)
			if (name.toLowerCase() == file.toLowerCase())
			{
				LogHelper.warn('Please import the file as \'$name\' instead of \'$file\'.');
				targetFile = _file;
				break;
			}
		}

		// If not file targetted, skip
		if (targetFile == null)
			throw('Could not find the file named \'$file\'.');

		script.importFile(targetFile);
	}

	/**
	 * Calls the given method in this script and its children
	 * @param name Name of the method to call
	 * @param args Arguments to use
	 * @return Array<Null<Dynamic>> Results of the calls
	 */
	public static function callMethod(name:Null<String> = null, args:Dynamic = null):Map<String, Null<Dynamic>>
	{
		// If invalid
		if (name == null)
			throw('No function was given to call.');

		var script:Null<LuaScript> = LuaCache.GetScript();

		if (script == null)
			throw('Tried to call a method from an invalid script.');

		if (args == null)
			args = [];

		return script.call(name, args, true);
	}
}
