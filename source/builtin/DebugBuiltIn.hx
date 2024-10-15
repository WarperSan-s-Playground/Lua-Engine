package builtin;

import helpers.DebugHelper;
import engine.Script;
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

	public static function printState():Void
	{
		var result:String = DebugHelper.printState();

		// Save the resullt to a file
		var file = sys.io.File.write("output.txt");
		file.writeString(result);
		file.close();
	}
}
