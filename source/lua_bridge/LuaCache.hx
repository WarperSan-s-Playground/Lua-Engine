package lua_bridge;

import custom.PointerMap;
import helpers.LogHelper;
import sys.thread.Thread;
import llua.State;

class LuaCache
{
	private static var runningScripts:PointerMap<State, LuaScript> = new PointerMap<State, LuaScript>();
	private static var lastScriptRan:Map<Dynamic, LuaScript> = new Map<Dynamic, LuaScript>();

	/**
	 * Sets the script related to the given state as the last script ran in the thread
	 * @param lua State related to the script
	 */
	public static function SetLastScript(lua:State):Void
	{
		// Get script from state
		if (!runningScripts.exists(lua))
			return;

		// Set script to thread
		var script:LuaScript = runningScripts.get(lua);
		lastScriptRan.set(Thread.current(), script);
	}

	/**
	 * Fetches the last script ran on this thread
	 * @return Last script ran or null if nothing found
	 */
	public static function GetScript():Null<LuaScript>
	{
		var current:Thread = Thread.current();

		if (!lastScriptRan.exists(current))
		{
			LogHelper.warn("Tried to fetch the last script in a thread that never ran a script.");
			return null;
		}

		return lastScriptRan.get(current);
	}

	/** Links the given script to the given state */
	public static function LinkScript(lua:State, script:LuaScript):Void
	{
		// If exists, skip
		if (runningScripts.exists(lua))
		{
			LogHelper.warn("Tried to register a script to a state that is already linked to another script.");
			return;
		}

		runningScripts.set(lua, script);
	}

	/** Unlinks the given script from the given state if they were linked */
	public static function UnlinkScript(lua:State, script:LuaScript):Void
	{
		// If not found, skip
		if (!runningScripts.exists(lua))
			return;

		// If not valid, skip
		if (runningScripts.get(lua) != script)
		{
			LogHelper.warn("Tried to illegally unlink a script.");
			return;
		}

		runningScripts.remove(lua);
	}
}
