package builtin;

import engine.ScriptCache;
import engine.Script;

/** Class holding every built-in methods for data */
@:rtti
class DataBuiltIn
{
	/**
	 * Stores in the shared space the given value at the given key
	 * @param key Key to store at
	 * @param value Value to store
	 * @param overwrite Overwrites the value if already found
	 * @param inRoot Store in root
	 */
	public static function setShared(key:Null<String> = null, value:Dynamic = null, overwrite:Bool = false, inRoot:Bool = true):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to set a shared value without providing a key.');

		// Get root
		var script:Script = ScriptCache.GetScript();

		if (script == null)
			throw('Tried to set a shared value to an invalid script.');

		// Set data
		script.Shared.set(key, value, overwrite, inRoot);
	}

	/**
	 * Fetches the value associated with the given key in the shared space
	 * @param key Key to look for
	 * @return Value found
	 */
	public static function getShared(key:Null<String> = null):Dynamic
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to get a shared value without providing a key.');

		// Get root
		var script:Script = ScriptCache.GetScript();

		if (script == null)
			throw('Tried to get a shared value to an invalid script.');

		// Get data
		return script.Shared.get(key);
	}

	/**
	 * Removes in the shared space the value associated with the given key
	 * @param key Key to remove
	 */
	public static function removeShared(key:Null<String> = null):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to remove a shared value without providing a key.');

		// Get root
		var script:Script = ScriptCache.GetScript();

		if (script == null)
			throw('Tried to remove a shared value to an invalid script.');

		script.Shared.remove(key);
	}

	/**
	 * Stores the given value at the given key in the global space
	 * @param key Key to store at
	 * @param value Value to store
	 * @param overwrite Overwrites the value if already found
	 */
	public static function setGlobal(key:Null<String> = null, value:Dynamic = null, overwrite:Bool = false):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to set a global value without providing a key.');

		// Set data
		Script.Global.set(key, value, overwrite);
	}

	/**
	 * Fetches the value associated with the given key in the global space
	 * @param key Key to look for
	 * @return Value found
	 */
	public static function getGlobal(key:Null<String> = null):Dynamic
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to get a global value without providing a key.');

		// Get data
		return Script.Global.get(key);
	}

	/**
	 * Removes the value associated with the given key in the global space
	 * @param key Key to remove
	 */
	public static function removeGlobal(key:Null<String> = null):Void
	{
		// If key invalid, skip
		if (key == null)
			throw('Tried to remove a global value without providing a key.');

		// Remove data
		Script.Global.remove(key);
	}
}
