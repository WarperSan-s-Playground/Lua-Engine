package engine.lua;

import llua.State;
import llua.Convert;
import llua.Lua;

class LuaConvert
{
	public static function fromLua(lua:State, i:Int, offset:Int):Dynamic
	{
		var type:Int = Lua.type(lua, i);

		// If null, return null
		if (type == Lua.LUA_TNONE)
			return null;

		// If not a table, use pre-made
		if (type != Lua.LUA_TTABLE)
			return Convert.fromLua(lua, i);

		var orderArgs:Array<Dynamic> = [];
		var unorderArgs:Map<Dynamic, Dynamic> = new Map<Dynamic, Dynamic>();
		var hasOrder:Bool = true;

		// Add padding
		Lua.pushnil(lua);

		var start = i - offset;
		start -= 1; // Offset from padding

		// Load table
		Lua.gettable(lua, start);

		while (Lua.next(lua, start) != 0)
		{
			var key:String = Std.string(fromLua(lua, -2, 0));
			var value:Dynamic = fromLua(lua, -1, 0);

			// Set value
			unorderArgs.set(key, value);
			orderArgs.push(value);

			if (hasOrder && key != Std.string(orderArgs.length))
				hasOrder = false;

			// Remove the value, keep the key for next iteration
			Lua.pop(lua, 1);
		}

		// Remove padding
		Lua.pop(lua, 0);

		return hasOrder ? orderArgs : unorderArgs;
	}

	public static function toLua(lua:State, value:Dynamic):Void
	{
		// If value is null, return null
		if (value == null)
		{
			Lua.pushnil(lua);
			return;
		}

		var primitiveTypes:Array<Dynamic> = [Int, Float, Bool, String, Array, haxe.ds.StringMap];

		for (i in primitiveTypes)
		{
			// If value is primitive type, return base value
			if (Std.isOfType(value, i))
			{
				Convert.toLua(lua, value);
				return;
			}
		}

		// If not a class or an annonymous object, return null
		if (Type.typeof(value) != Type.ValueType.TObject)
		{
			Lua.pushnil(lua);
			return;
		}

		// If a class, return class name
		if (Reflect.field(value.value, "__class__") != null)
		{
			Lua.pushstring(lua, Std.string(value.value));
			return;
		}

		Lua.createtable(lua, 0, 0); // Create an empty table

		// Iterate over the fields of the Haxe object
		for (n in Reflect.fields(value))
		{
			Lua.pushstring(lua, n); // Push the field name as a key
			toLua(lua, Reflect.field(value, n)); // Convert the field value to Lua
			Lua.settable(lua, -3); // Set the key-value pair in the table
		}
	}
}
