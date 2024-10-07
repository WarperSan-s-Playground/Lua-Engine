package engine;

import helpers.LogHelper;
import custom.PointerMap;
import sys.thread.Thread;

/** Class that manages the access of scripts from a value or from a thread */
class ScriptCache
{
    private static var runningScripts:PointerMap<Dynamic, Script> = new PointerMap<Dynamic, Script>();
	private static var lastScriptRan:Map<Dynamic, Script> = new Map<Dynamic, Script>();

	/**
	 * Sets the script related to the given key as the last script ran in the thread
	 * @param lua State related to the script
	 */
	public static function SetLastScript(key:Dynamic):Void
	{
		// Get script from state
		if (!runningScripts.exists(key))
			return;

		// Set script to thread
		var script:Script = runningScripts.get(key);
		lastScriptRan.set(Thread.current(), script);
	}

	/**
	 * Fetches the last script ran on this thread
	 * @return Last script ran or null if nothing found
	 */
	public static function GetScript():Null<Script>
	{
		var current:Thread = Thread.current();

		if (!lastScriptRan.exists(current))
		{
			LogHelper.warn("Tried to fetch the last script in a thread that never ran a script.");
			return null;
		}

		return lastScriptRan.get(current);
	}

	/** Links the given script to the given key */
	public static function LinkScript(key:Dynamic, script:Script):Void
	{
		// If exists, skip
		if (runningScripts.exists(key))
		{
			LogHelper.warn("Tried to register a script to a state that is already linked to another script.");
			return;
		}

		runningScripts.set(key, script);
	}

	/** Unlinks the given script from the given key if they were linked */
	public static function UnlinkScript(key:Dynamic, script:Script):Void
	{
		// If not found, skip
		if (!runningScripts.exists(key))
			return;

		// If not valid, skip
		if (runningScripts.get(key) != script)
		{
			LogHelper.warn("Tried to illegally unlink a script.");
			return;
		}

		runningScripts.remove(key);
	}
}