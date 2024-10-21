package custom;

import haxe.ds.StringMap;
import helpers.DebugHelper;
import interfaces.IMeasurable;
import engine.script.Script;

/** Class that manages the data sharing between scripts */
class DataContainer implements IMeasurable
{
	private var data:StringMap<Dynamic> = new StringMap<Dynamic>();
	private var script:Null<Script>;

	public function new(script:Null<Script>)
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
			parent = this.script.Parent;

		// If in root and has parent, continue
		if (inRoot && parent != null)
		{
			parent.Shared.set(key, value, overwrite, true);
			return;
		}

		// If not overwrite and key exists, error
		if (!overwrite && this.data.exists(key))
		{
			if (this.script != null)
				throw('The key \'$key\' already exists in the shared space of \'${this.script.File}\'.');
			throw('The key \'$key\' already exists in the global space.');
		}

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
			parent = this.script.Parent;

		// If no parent, error
		if (parent == null)
			throw('No data in the shared space is associated with the key \'$key\'.');

		return parent.Shared.get(key);
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
			parent = this.script.Parent;

		// If no parent, error
		if (parent == null)
			return;

		parent.Shared.remove(key);
	}

	public function getSize():Int
	{
		var size = 0;

		for (i in this.data.keys())
		{
			size += DebugHelper.getSize(i);
			size += DebugHelper.getSize(this.data.get(i));
		}

		return size;
	}
}
