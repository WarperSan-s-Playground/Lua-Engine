package engine.lua;

import engine.script.Message;
import engine.script.Script;
import helpers.LogHelper;
import haxe.Exception;
import llua.Lua;
import llua.LuaL;
import llua.State;

/** Class that represents an instance of a .lua script */
class LuaScript extends Script
{
	public function new(file:String, parent:Null<Script>)
	{
		super(file, parent);

		this.lua = LuaL.newstate();
		this.LinkKey = this.lua;
	}

	private var lua:State;

	// #region Execute

	public function execute():Void
	{
		// Open standard libraries
		LuaL.openlibs(this.lua);

		// Make print use trace
		LuaL.dostring(this.lua, "print = trace;");

		// Load file
		var status:Int = LuaL.dofile(this.lua, this.File);

		if (status != Lua.LUA_OK)
			throw(Lua.tostring(this.lua, status));
	}

	/**
	 * Calls the given method in the given LuaScript
	 * @param lua File that called
	 * @param name Name of the method to call
	 * @return The method returned a value
	 */
	public static function callback(lua:State, name:String):Int
	{
		// Update the last script
		ScriptCache.SetLastScript(lua);

		var result:Dynamic = null;

		try
		{
			var callback:Dynamic = Lua_helper.callbacks.get(name);

			// If callback invalid, skip
			if (callback == null)
				throw('No callback named \'$name\' was found.');

			// Create arguments
			var paramCount:Int = Lua.gettop(lua);
			var args:Array<Dynamic> = [];

			for (i in 0...paramCount)
				args.push(LuaConvert.fromLua(lua, i + 1, paramCount + 1));

			// Call method
			var value:Dynamic = Reflect.callMethod(null, callback, args);
			result = success(value);
		}
		catch (e:Exception)
		{
			var script:Null<Script> = ScriptCache.GetScript();
			var file:String = "undefined";

			if (script != null)
			{
				file = script.File;
				script.State = ERRORED;
			}

			LogHelper.error('Error while calling \'$name\' in \'$file\': ${e.message}');
			result = error(e.message);
		}

		LuaConvert.toLua(lua, result);
		return 1; // Has return value
	}

	public function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		Lua.getglobal(this.lua, name);

		var type:Int = Lua.type(this.lua, -1);

		// If not found, skip
		if (type == Lua.LUA_TNIL)
			return null;

		// If not function, error
		if (type != Lua.LUA_TFUNCTION)
			throw('Tried to call \'$name\', but it is not a function.');

		// Put arguments
		for (arg in args)
			LuaConvert.toLua(this.lua, arg);

		// Call
		var error:Int = Lua.pcall(this.lua, args.length, 1, 0);

		var value:Dynamic = LuaConvert.fromLua(this.lua, -1, 0);

		if (error != 0)
			throw(value);

		Lua.pop(lua, 1);

		return success(value);
	}

	// #endregion

	private inline function set(name:String, value:Dynamic):Void
	{
		if (Reflect.isFunction(value))
		{
			Lua_helper.add_callback(this.lua, name, value);
			return;
		}
	}

	private inline function destroy():Void
		Lua.close(this.lua);
}
