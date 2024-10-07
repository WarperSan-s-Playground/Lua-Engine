package builtin;

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
			results.push(i.getFile());

		return results;
	}
}
