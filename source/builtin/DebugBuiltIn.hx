package builtin;

import helpers.DebugHelper;
import engine.script.Script;
import engine.ScriptParenting;

/** Class holding every built-in methods for debugging */
@:rtti
class DebugBuiltIn
{
	/** Fetches all the scripts loaded */
	public static function getAllScripts():Array<String>
	{
		var scripts:Array<Script> = ScriptParenting.GetAll(true);
		var results:Array<String> = [];

		for (i in scripts)
			results.push(i.File);

		return results;
	}

	/**
	 * Prints the current state of the game into the given file
	 * @param file File to print to
	 */
	public static function printState(file:String = null):Void
	{
		if (file == null)
			file = "output.txt";

		var result:String = DebugHelper.printState();

		// Save the resullt to a file
		var file = sys.io.File.write(file);
		file.writeString(result);
		file.close();
	}
}
