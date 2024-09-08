package helpers;

import helpers.LogHelper;
import llua.Convert;
import llua.Lua;
import llua.State;
import lua_bridge.LuaCache;
import lua_bridge.LuaMessage;

class LuaHelper
{
	/**
	 * Fetches the object with the given ID
	 * @param id ID of the object
	 * @return Object fetched
	 */
	public static function getObject(id:Int):flixel.FlxBasic
	{
		// If id invalid, skip
		if (id < 0)
			throw('The ID \'$id\' is not valid.');

		var state:flixel.FlxState = flixel.FlxG.state;

		// If state invalid, skip
		if (state == null)
			throw('Invalid state.');

		var basic:Null<flixel.FlxBasic> = state.getFirst((b:flixel.FlxBasic) ->
		{
			return b.ID == id && Std.isOfType(b, flixel.FlxSprite);
		});

		// If basic not found, skip
		if (basic == null)
			throw('Could not find a ${flixel.FlxSprite} with the ID \'$id\'.');

		return basic;
	}

	// #region Add

	/**
	 * Adds the given function to the given lua script
	 * @param lua Script to add to
	 * @param name Name of the function
	 * @param Callback of the function
	 */
	public static function add(lua:State, name:String, func:Dynamic):Void
	{
		Lua_helper.add_callback(lua, name, func);
	}

	/**
	 * Adds all the functions from the given object as a callback
	 * @param lua Script to add to
	 * @param Object to fetch the functions from
	 */
	public static function addAll(lua:State, o:Dynamic):Void
	{
		var fields:Array<String> = Type.getClassFields(o);

		// Add each field
		for (field in fields)
		{
			var callback:Dynamic = Reflect.field(o, field);

			// If not a function, skip
			if (!Reflect.isFunction(callback))
				continue;

			LuaHelper.add(lua, field, callback);
		}
	}

	// #endregion
	// #region Call

	/**
	 * Calls the given method in the given LuaScript
	 * @param lua File that called
	 * @param name Name of the method to call
	 * @return The method returned a value
	 */
	public static function callback(lua:State, name:String):Int
	{
		// Update the last script
		LuaCache.SetLastScript(lua);

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
				args[i] = Convert.fromLua(lua, i + 1);

			// Call method
			var value:Dynamic = Reflect.callMethod(null, callback, args);
			result = LuaMessage.success(value);
		}
		catch (e:String)
		{
			LogHelper.error('Error while calling \'$name\': $e');
			result = LuaMessage.error(e);
		}

		Convert.toLua(lua, result);
		return 1; // Has return value
	}

	/**
	 * Calls the given method in the given file
	 * @param lua File to call
	 * @param name Name of the method to call
	 * @param args Arguments to pass
	 * @return LuaMessage or null if not found
	 */
	public static function call(lua:State, name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		var result:Dynamic = null;

		try
		{
			Lua.getglobal(lua, name);

			var type:Int = Lua.type(lua, -1);

			// If not found, skip
			if (type == Lua.LUA_TNIL)
				return null;

			// If not function, error
			if (type != Lua.LUA_TFUNCTION)
				throw('Tried to call \'$name\', but it is not a function.');

			// Put arguments
			for (arg in args)
				Convert.toLua(lua, arg);

			// Call
			Lua.pcall(lua, args.length, 1, 0);

			var value:Dynamic = Convert.fromLua(lua, -1);
			result = LuaMessage.success(value);
			Lua.pop(lua, 1);
		}
		catch (e:String)
		{
			LogHelper.error('Error while invoking \'$name\': $e');
			result = LuaMessage.error(e);
		}

		return result;
	}

	// #endregion
}
