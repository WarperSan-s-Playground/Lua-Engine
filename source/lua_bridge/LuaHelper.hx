package lua_bridge;

import helpers.LogHelper;
import llua.Convert;
import llua.Lua;
import llua.Lua.Lua_helper;
import llua.State;

class LuaHelper
{
	/**
	 * Calls the given method in the given script
	 * @param lua Lua script to target
	 * @param name Name of the method to call
	 * @return Int The method returned a value
	 */
	public static function call(lua:State, name:String):Int
	{
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
			result = LuaError.success(value);
		}
		catch (e:String)
		{
			LogHelper.error('Error while calling \'$name\': $e');
			result = LuaError.error(e);
		}

		Convert.toLua(lua, result);
		return 1; // Has return value
	}

	/**
	 * Adds the given function to the given lua script
	 * @param lua Script to add to
	 * @param name Name of the function
	 * @param func Callback of the function
	 */
	public static function add(lua:State, name:String, func:Dynamic):Void
	{
		// If added
		if (Lua_helper.callbacks.exists(name))
		{
			LogHelper.warn('The function \'$name\' was already added.');
			return;
		}

		Lua_helper.add_callback(lua, name, func);
		LogHelper.debug('The function \'$name\' was added to the current file.');
	}

	/**
	 * Adds all the functions from the given object as a callback
	 * @param lua Script to add to
	 * @param o Object to fetch the functions from
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
			{
				LogHelper.warn('The field \'$field\' is invalid for a callback.');
				continue;
			}

			LuaHelper.add(lua, field, callback);
		}
	}

	/**
	 * Fetches the object with the given ID
	 * @param id ID of the object
	 * @return flixel.FlxBasic Object fetched
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
}
