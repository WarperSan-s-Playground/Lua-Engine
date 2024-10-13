package builtin;

import engine.ScriptParenting;
import engine.ScriptCache;
import engine.Script;
import lua_bridge.LuaImport;
import helpers.LogHelper;
import helpers.FileHelper;

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
	public static function addScript(file:Null<String> = null, autoImport:Bool = true, isRelated:Bool = true):Dynamic
	{
		var fixed:String = FileHelper.GetPath(file);

		// File not found
		if (fixed == null)
			throw('Could not find a file at \'$file\'.');

		var child:Null<Script> = null;

		// Create the script as child
		if (isRelated)
		{
			var script:Null<Script> = ScriptCache.GetScript();

			if (script == null)
				throw('Tried to add a script from an invalid script.');

			child = script.openOther(file, autoImport);
		}
		else
			child = Script.openFile(file, autoImport);

		if (child == null)
			throw('Failed to create a script for the file \'$file\'.');

		var it = Script.LastCallResult.iterator();

		if (!it.hasNext())
			return null;

		var value = it.next();

		if (value == null)
			return value;

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

		var script:Null<Script> = ScriptParenting.Find(file);

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

		var script:Null<Script> = ScriptCache.GetScript();

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

		var script:Null<Script> = ScriptCache.GetScript();

		if (script == null)
			throw('Tried to call a method from an invalid script.');

		if (args == null)
			args = [];

		return script.call(name, args, true);
	}
}
