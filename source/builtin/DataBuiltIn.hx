package builtin;

import lua_bridge.LuaScript;
import lua_bridge.LuaCache;

/** Class holding every built-in methods for data */
class DataBuiltIn
{
	/**
	 * Stores the given value to the given key as a global
	 * @param key Key to store at
	 * @param value Value to store
	 * @param overwrite Overwrites the value if already found
     * @param inRoot Store in root
	 */
	public static function setGlobal(key:Null<String> = null, value:Dynamic = null, overwrite:Bool = false, inRoot:Bool = true):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to set a global value without providing a key.');

		// Get root
		var script:LuaScript = LuaCache.GetScript();

		if (script == null)
			throw('Tried to set a global value to an invalid script.');

		// Set data
		script.setData(key, value, overwrite, inRoot);
	}

	/**
	 * Fetches the value associated with the given key
	 * @param key Key to look for
	 * @return Value found
	 */
	public static function getGlobal(key:Null<String> = null):Dynamic
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to get a global value without providing a key.');

		// Get root
		var script:LuaScript = LuaCache.GetScript();

		if (script == null)
			throw('Tried to get a global value to an invalid script.');

		// Get data
		return script.getData(key);
	}

	/**
	 * Removes the value associated with the given key
	 * @param key Key to remove
	 */
	public static function removeGlobal(key:Null<String> = null):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to remove a global value without providing a key.');

		// Get root
		var script:LuaScript = LuaCache.GetScript();

		if (script == null)
			throw('Tried to remove a global value to an invalid script.');
	}
}
