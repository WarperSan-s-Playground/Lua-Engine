package builtin;

import lua_bridge.LuaParenting;
import lua_bridge.LuaScript;

/** Class holding every built-in methods for debugging */
@:rtti
class DebugBuiltIn
{
	/** Fetches all the scripts loaded */
	public static function getAllScripts():Array<String>
	{
		var scripts:Array<LuaScript> = LuaParenting.GetAll(true);
		var results:Array<String> = [];

		for (i in scripts)
			results.push(i.file);

		return results;
	}
}
