package engine;

import llua.Convert;
import helpers.LogHelper;
import haxe.Exception;
import lua_bridge.LuaImport;
import custom.DataContainer;
import llua.Lua;
import llua.LuaL;
import llua.State;

typedef LuaMessage =
{
	var message:String;
	var value:Null<Dynamic>;
	var isError:Bool;
}

/** Class that represents an instance of a Lua script */
class LuaScript extends engine.Script
{
	public function new(file:String, parent:Null<Script>, autoImport:Bool)
	{
		super(file, parent);

		this.setLua(autoImport);

		// Set data
		this.Shared = new DataContainer(this);
	}

	// #region Lua
	private var lua:llua.State;

	/**
	 * Sets the lua state
	 * @param autoImport Automatically imports all the built-in functions
	 */
	private function setLua(autoImport:Bool):Void
	{
		this.lua = LuaL.newstate();
		this.LinkKey = this.lua;

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

		add(this.lua, name, callback);
	}

	/**
	 * Adds the given function to the given lua script
	 * @param lua Script to add to
	 * @param name Name of the function
	 * @param Callback of the function
	 */
	private static function add(lua:State, name:String, func:Dynamic):Void
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

			add(lua, field, callback);
		}
	}

	// #endregion
	// #region Execute

	/** Executes this script */
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
				args.push(fromLua(lua, i + 1, paramCount + 1));

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
				script.State = Errored;
			}

			LogHelper.error('Error while calling \'$name\' in \'$file\': ${e.message}');
			result = error(e.message);
		}

		toLua(lua, result);
		return 1; // Has return value
	}

	/**
	 * Calls the given method in the given file
	 * @param name Name of the method to call
	 * @param args Arguments to pass
	 * @return LuaMessage or null if not found
	 */
	public function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		var result:Dynamic = null;

		try
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
				toLua(this.lua, arg);

			// Call
			var error:Int = Lua.pcall(this.lua, args.length, 1, 0);

			var value:Dynamic = fromLua(this.lua, -1, 0);

			if (error != 0)
				throw(value);

			result = success(value);
			Lua.pop(lua, 1);
		}
		catch (e:Exception)
		{
			var script:Null<Script> = ScriptCache.GetScript();
			var file:String = "undefined";

			if (script != null)
			{
				file = script.File;
				script.State = Errored;
			}

			LogHelper.error('Error while invoking \'$name\' in \'$file\': ${e.message}');
			result = error(e.message);
		}

		return result;
	}

	/**
	 * Creates a success
	 * @param value Value of the success
	 */
	private inline static function success(value:Null<Dynamic>):LuaMessage
		return {message: "Success.", value: value, isError: false};

	/**
	 * Creates an error
	 * @param message Message of the error
	 * @param value Value of the error
	 */
	private inline static function error(message:String = "Message undefined", value:Null<Dynamic> = false):LuaMessage
		return {message: message, value: value, isError: true};

	// #endregion
	// #region Convert

	private static function fromLua(lua:State, i:Int, offset:Int):Dynamic
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

	private static function toLua(lua:State, value:Dynamic):Void
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

	// #endregion
	// #region Close

	private function destroy():Void
	{
		Lua.close(this.lua);
	}

	// #endregion
}
