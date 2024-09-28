package lua_bridge;

import custom.DataContainer;
import helpers.FileHelper;
import helpers.LogHelper;
import helpers.LuaHelper;
import llua.Lua;
import llua.LuaL;
import llua.State;

/**
 * Class that represents an instance of a Lua script
 */
class LuaScript
{
	// #region OPEN

	/**
	 * Creates a script from the given file
	 * @param file File to load from
	 * @param parent Parent of the script
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Created script
	 */
	private static function create(file:String, parent:Null<LuaScript>, autoImport:Bool):Null<LuaScript>
	{
		// Create script
		var script:Null<LuaScript> = null;

		try
		{
			script = new LuaScript(file, parent, autoImport);
			script.execute();

			// Callback
			var hasParent:Bool = parent != null;
			script.call("OnCreate", [hasParent], false);
		}
		catch (e:String)
		{
			LogHelper.error('Error while creating a $LuaScript from \'$file\': $e');
			script = null;
		}

		return script;
	}

	/**
	 * Opens the given file as a lua script
	 * @param file File to open
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Script created
	 */
	public static function openFile(file:String, autoImport:Bool):Null<LuaScript>
	{
		return LuaScript.create(file, null, autoImport);
	}

	/**
	 * Opens another file that is related to this one. If this script closes, the other script closes too.
	 * @param file File to open
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Script created
	 */
	public function openOther(file:String, autoImport:Bool):Null<LuaScript>
	{
		return LuaScript.create(file, this, autoImport);
	}

	// #endregion
	// #region CONSTRUCTOR
	public var file:String;

	private var lua:llua.State;

	private function new(file:String, parent:Null<LuaScript>, autoImport:Bool)
	{
		this.setFile(file);
		this.setLua(autoImport);
		LuaParenting.SetParent(this, parent);
		this.shared = new DataContainer(this);
	}

	/** Sets the current file to the given file */
	private function setFile(file:String):Void
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.file = fixed;
	}

	/**
	 * Sets the lua state
	 * @param autoImport Automatically imports all the built-in functions
	 */
	private function setLua(autoImport:Bool):Void
	{
		this.lua = LuaL.newstate();

		var methods:Array<Dynamic> = LuaImport.getBuiltIn(autoImport);

		// Add every built-in methods
		var i:Int = 0;
		while (i < methods.length)
		{
			this.importFile(methods[i]);
			i++;
		}
	}

	// #endregion
	// #region IMPORTS

	/**
	 * Imports a single method to this script
	 * @param name Name of the method
	 * @param callback Action to call
	 */
	public function importMethod(name:String, callback:Dynamic):Void
	{
		LuaHelper.add(this.lua, name, callback);
	}

	/**
	 * Imports a whole class to this script
	 * @param builtIn Class to import from
	 */
	public function importFile(builtIn:Dynamic):Void
	{
		var fields:Array<String> = Type.getClassFields(builtIn);

		// Add each field
		for (field in fields)
		{
			var callback:Dynamic = Reflect.field(builtIn, field);

			// If not a function, skip
			if (!Reflect.isFunction(callback))
				continue;

			this.importMethod(field, callback);
		}
	}

	// #endregion
	// #region DATA
	public var shared:custom.DataContainer;

	public static var global:custom.DataContainer = new custom.DataContainer(null);

	// #endregion
	// #region EXECUTE

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

		// Call in self
		results.push(LuaHelper.call(this.lua, name, args));

		if (callInChildren)
		{
			for (child in LuaParenting.GetChildren(this))
			{
				for (r in child.call(name, args, callInChildren))
					results.push(r);
			}
		}

		return results;
	}

	// #endregion
	// #region CLOSE
	public var isClosed:Bool = false;

	/** Closes this script and the related scripts */
	public function close()
	{
		// If already closed, skip
		if (this.isClosed)
			return;

		this.isClosed = true;

		// Close children
		for (child in LuaParenting.GetChildren(this))
		{
			// If invalid or already closed, skip
			if (child == null || child.isClosed)
				continue;

			child.close();
		}

		// Callback
		this.call("OnDestroy", [], false);

		// Close self
		LuaCache.UnlinkScript(this.lua, this);
		LuaParenting.RemoveParent(this);
		llua.Lua.close(this.lua);
	}

	// #endregion
}
