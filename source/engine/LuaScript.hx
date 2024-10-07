package engine;

import lua_bridge.LuaImport;
import custom.DataContainer;
import helpers.LogHelper;
import helpers.LuaHelper;
import llua.Lua;
import llua.LuaL;
import llua.State;

/** Class that represents an instance of a Lua script */
class LuaScript extends engine.Script
{
	public function new(file:String, parent:Null<Script>, autoImport:Bool)
	{
		super(file, parent);

		this.setLua(autoImport);

		// Set data
		this.shared = new DataContainer(this);
	}

	// #region State
	private var lua:llua.State;

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
	// #region Import

	public override function importMethod(name:String, callback:Dynamic):Void
	{
		if (callback == null)
			throw('Could not add the method \'$name\'.');

		LuaHelper.add(this.lua, name, callback);
	}

	// #endregion
	// #region Execute

	/** Executes this script */
	public function execute():Void
	{
		try
		{
			// Open standard libraries
			LuaL.openlibs(this.lua);

			// Default config
			LuaL.dostring(this.lua, "print = function(...) trace(...); end");

			// Load file
			var status:Int = LuaL.dofile(this.lua, this.file);

			if (status != Lua.LUA_OK)
				throw(Lua.tostring(this.lua, status));
		}
		catch (e:String)
		{
			LogHelper.error('Error while executing \'${this.file}\': $e');
		}
	}

	public function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		return LuaHelper.call(this.lua, name, args);
	}

	// #endregion
	// #region Link

	public function getLinkKey():Dynamic
	{
		return this.lua;
	}

	// #endregion
	// #region Close

	private function destroy():Void
	{
		llua.Lua.close(this.lua);
	}

	// #endregion
}
