package lua_bridge;

import haxe.ds.GenericStack;
import helpers.FileHelper;
import helpers.LogHelper;
import helpers.LuaHelper;
import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaScript
{
	public var isClosed:Bool = false;

	/** Closes this script and the related scripts */
	public function close()
	{
		// If already closed, skip
		if (this.isClosed)
			return;

		this.isClosed = true;

		// Close children
		for (child in this.children)
		{
			// If invalid or already closed, skip
			if (child == null || child.isClosed)
				continue;

			child.close();
		}

		// Close self
		LuaCache.UnlinkScript(this.lua, this);
		llua.Lua.close(this.lua);
		roots.remove(this);
	}

	// #region Constructor
	public var file:String;

	private var lua:llua.State;

	private function new(file:String, parent:Null<LuaScript>)
	{
		this.setFile(file);
		this.setLua();
		this.setParent(parent);
	}

	/**
	 * Creates a script from the given file
	 * @param file File to load from
	 * @param parent Parent of the script
	 * @return Created script
	 */
	private static function create(file:String, parent:Null<LuaScript>):Null<LuaScript>
	{
		// Create script
		var script:Null<LuaScript> = null;

		try
		{
			script = new LuaScript(file, parent);
			script.execute();
		}
		catch (e:String)
		{
			LogHelper.error('Error while creating a $LuaScript from \'$file\': $e');
			script = null;
		}

		return script;
	}

	/** Sets the current file to the given file */
	private function setFile(file:String):Void
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.file = fixed;
	}

	/** Sets the lua state */
	private function setLua():Void
	{
		this.lua = LuaL.newstate();

		// Add every built-in methods
		LuaHelper.addAll(this.lua, builtin.SpriteBuiltIn);
		LuaHelper.addAll(this.lua, builtin.AnimationBuiltIn);
		LuaHelper.addAll(this.lua, builtin.LogBuiltIn);
		LuaHelper.addAll(this.lua, builtin.FileBuiltIn);
		LuaHelper.addAll(this.lua, builtin.DataBuiltIn);
		LuaHelper.addAll(this.lua, builtin.StateBuiltIn);
	}

	// #endregion
	// #region Root
	private static var roots:Array<LuaScript> = new Array<LuaScript>(); // Root scripts

	/**
	 * Opens the given file as a lua script
	 * @param file File to open
	 * @return Script created
	 */
	public static function openFile(file:String):Null<LuaScript>
	{
		return LuaScript.create(file, null);
	}

	/**
	 * Finds the first script that is the given file
	 * @param file File to search for
	 * @return Script that is the given file
	 */
	public static function findScript(file:String):Null<LuaScript>
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		var script:Null<LuaScript> = null;

		for (root in roots)
		{
			script = root.findScriptInside(fixed);

			// If found, stop
			if (script != null)
				break;
		}

		return script;
	}

	/**
	 * Finds the first script that is the given file
	 * @param file File to search for
	 * @return Script that is the given file
	 */
	private function findScriptInside(file:String):Null<LuaScript>
	{
		// If looking for this, skip
		if (this.file == file)
			return this;

		var script:Null<LuaScript> = null;

		for (child in this.children)
		{
			script = child.findScriptInside(file);

			// If found, stop
			if (script != null)
				break;
		}

		return script;
	}

	// #endregion
	// #region Parenty
	private var parent:Null<LuaScript> = null; // Parent of this script
	private var children:Array<LuaScript> = new Array<LuaScript>(); // Children of this script

	/**
	 * Opens another file that is related to this one. If this script closes, the other script closes too.
	 * @param file File to open
	 * @return Script created
	 */
	public function openOther(file:String):Null<LuaScript>
	{
		return LuaScript.create(file, this);
	}

	/** Sets the parent of this script to the given parent */
	private function setParent(parent:Null<LuaScript>):Void
	{
		// If root, add to roots
		if (parent == null)
		{
			roots.push(this);
		}
		else
		{
			parent.children.push(this);
			this.parent = parent;
		}

		this.call("OnParentChanged", [parent], false);
	}

	// #endregion
	// #region Data
	private var data:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * Stores the given data to the given key
	 * @param key Key to use
	 * @param value Value to store
	 * @param overwrite Overwrites the value if already found
	 * @param inRoot Store in root
	 */
	public function setData(key:String, value:Dynamic, overwrite:Bool = false, inRoot:Bool = true):Void
	{
		// If in root and has parent, continue
		if (inRoot && this.parent != null)
		{
			this.parent.setData(key, value, overwrite, true);
			return;
		}

		// If not overwrite and key exists, error
		if (!overwrite && this.data.exists(key))
			throw('The key \'$key\' already exists for \'$file\'.');

		var old:Dynamic = this.data.get(key);
		var msg:Dynamic = this.call("OnDataSet", [old, value, key], false)[0];

		if (!LuaMessage.isError(msg))
			value = msg.value;

		this.data.set(key, value);
	}

	/**
	 * Fetches the data associated with the given key
	 * @param key Key to look for
	 * @return Data fetched
	 */
	public function getData(key:String):Dynamic
	{
		// If exists, return
		if (this.data.exists(key))
			return this.data.get(key);

		// If no parent, error
		if (this.parent == null)
			throw('No data is associated with the key \'$key\'.');

		return this.parent.getData(key);
	}

	/**
	 * Removes the data associated with the given key
	 * @param key Key to remove
	 */
	public function removeData(key:String):Void
	{
		// If removed, skip
		if (this.data.remove(key))
			return;

		// If no parent, error
		if (this.parent == null)
			return;

		this.parent.removeData(key);
	}

	// #endregion
	// #region Executing

	/** Executes this script */
	public function execute():Void
	{
		try
		{
			LuaL.openlibs(this.lua);
			LuaCache.LinkScript(this.lua, this);
			var status:Int = LuaL.dofile(this.lua, this.file);

			if (status != Lua.LUA_OK)
				throw(Lua.tostring(this.lua, status));
		}
		catch (e:String)
		{
			LogHelper.error('Error while executing \'${this.file}\': $e');
		}
	}

	/** Calls the given method in this script and it's children */
	public function call(name:String, args:Array<Dynamic>, callInChildren:Bool):Array<Null<Dynamic>>
	{
		var results:Array<Null<Dynamic>> = [];
		var remaining:Array<LuaScript> = [this];

		while (remaining.length > 0)
		{
			var current:LuaScript = remaining.pop();

			// Skip if closed
			if (current.isClosed)
				continue;

			var result:Null<Dynamic> = LuaHelper.call(current.lua, name, args);

			results.push(result);

			// Call in children
			if (callInChildren)
			{
				for (child in current.children)
					remaining.push(child);
			}
		}

		return results;
	}

	// #endregion
}
