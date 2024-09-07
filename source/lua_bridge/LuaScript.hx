package lua_bridge;

import builtin.DataBuiltIn;
import helpers.FileHelper;
import llua.Lua;
import builtin.FileBuiltIn;
import llua.State;
import llua.LuaL;
import helpers.LogHelper;
import builtin.LogBuiltIn;
import builtin.AnimationBuiltIn;
import builtin.SpriteBuiltIn;

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
		rootScripts.remove(this);
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

	/** Executes this script */
	public function execute():Void
	{
		try
		{
			LuaL.openlibs(this.lua);
			LuaCache.LinkScript(this.lua, this);
			var index:Int = LuaL.dofile(this.lua, this.file);

			var result:Null<String> = Lua.tostring(this.lua, index);

			if (result != null)
				throw(result);
		}
		catch (e:String)
		{
			LogHelper.error('Error while executing \'${this.file}\': $e');
		}
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
		LuaHelper.addAll(this.lua, SpriteBuiltIn);
		LuaHelper.addAll(this.lua, AnimationBuiltIn);
		LuaHelper.addAll(this.lua, LogBuiltIn);
		LuaHelper.addAll(this.lua, FileBuiltIn);
		LuaHelper.addAll(this.lua, DataBuiltIn);
	}

	// #endregion
	// #region Root
	private static var rootScripts:Array<LuaScript> = new Array<LuaScript>(); // Root scripts

	/**
	 * Opens the given file as a lua script
	 * @param file File to open
	 * @return Script created
	 */
	public static function openFile(file:String):Null<LuaScript>
	{
		return LuaScript.create(file, null);
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
			rootScripts.push(this);
		}
		else
		{
			parent.children.push(this);
			this.parent = parent;
		}
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
}
