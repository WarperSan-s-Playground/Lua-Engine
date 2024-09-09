package custom;

import lua_bridge.LuaParenting;
import lua_bridge.LuaScript;

/**
 * Class that manages the data sharing between scripts
 */
class DataContainer
{
	private var data:Map<String, Dynamic> = new Map<String, Dynamic>();
	private var script:Null<LuaScript>;

	public function new(script:Null<LuaScript>)
	{
		this.script = script;
	}

	/**
	 * Stores the given value at the given key
	 * @param key Key to store at
	 * @param value Value to store
	 * @param overwrite Overwrites the value if already found
	 * @param inRoot Store in root
	 */
	public function set(key:String, value:Dynamic, overwrite:Bool = false, inRoot:Bool = true):Void
	{
		var parent = null;

		if (this.script != null)
			parent = LuaParenting.GetParent(this.script);

		// If in root and has parent, continue
		if (inRoot && parent != null)
		{
			parent.shared.set(key, value, overwrite, true);
			return;
		}

		// If not overwrite and key exists, error
		if (!overwrite && this.data.exists(key))
			throw('The key \'$key\' already exists in the shared space of \'${this.script.file}\'.');

		this.data.set(key, value);
	}

	/**
	 * Fetches the value associated with the given key
	 * @param key Key to look for
	 * @return Value found
	 */
	public function get(key:String):Dynamic
	{
		// If exists, return
		if (this.data.exists(key))
			return this.data.get(key);

		var parent = null;

		if (this.script != null)
			parent = LuaParenting.GetParent(this.script);

		// If no parent, error
		if (parent == null)
			throw('No data in the shared space is associated with the key \'$key\'.');

		return parent.shared.get(key);
	}

	/**
	 * Removes the value associated with the given key
	 * @param key Key to remove
	 */
	public function remove(key:String):Void
	{
		// If removed, skip
		if (this.data.remove(key))
			return;

		var parent = null;

		if (this.script != null)
			parent = LuaParenting.GetParent(this.script);

		// If no parent, error
		if (parent == null)
			return;

		parent.shared.remove(key);
	}
}
