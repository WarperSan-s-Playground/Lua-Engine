package builtin;

import engine.script.Script;
import engine.ScriptParenting;
import engine.ScriptCache;
import helpers.FileHelper;

/** Class holding every built-in methods for scripts */
@:rtti
class ScriptBuiltIn
{
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

		var child:Null<Script> = null;
		var script:Null<Script> = null;

		// Create the script as child
		if (isRelated)
		{
			script = ScriptCache.GetScript();

			if (script == null)
				throw('Tried to add a script from an invalid script.');
		}

		child = Script.openFile(file, script);

		if (child == null)
			throw('Failed to create a script for the file \'$file\'.');
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

		return script.Events.callMethod(name, args, true);
	}
}
