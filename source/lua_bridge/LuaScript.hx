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
	// #region Constructor
	public var file:String;

	private var lua:llua.State;

	private function new(file:String, parent:Null<LuaScript>)
	{
		this.setFile(file);
		this.setLua();
		LuaParenting.SetParent(this, parent);
		this.shared = new DataContainer(this);
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
		var builtins:Dynamic = getAllBuiltIn();

		var i:Int = 0;
		while (i < builtins.methods.length)
		{
			LuaHelper.add(this.lua, builtins.names[i], builtins.methods[i]);
			i++;
		}
	}

	public static var BUILT_IN:Array<Dynamic> = [
		builtin.SpriteBuiltIn,
		builtin.AnimationBuiltIn,
		builtin.LogBuiltIn,
		builtin.FileBuiltIn,
		builtin.DataBuiltIn,
		builtin.StateBuiltIn,
		builtin.DebugBuiltIn
	];

	public static function getAllBuiltIn():Dynamic
	{
		var methods:Array<Dynamic> = [];
		var names:Array<String> = [];

		for (bi in BUILT_IN)
		{
			var fields:Array<String> = Type.getClassFields(bi);

			// Add each field
			for (field in fields)
			{
				var callback:Dynamic = Reflect.field(bi, field);

				// If not a function, skip
				if (!Reflect.isFunction(callback))
					continue;

				methods.push(callback);
				names.push(field);
			}
		}

		return {
			methods: methods,
			names: names
		};
	}

	// #endregion
	// #region Open

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
	 * Opens another file that is related to this one. If this script closes, the other script closes too.
	 * @param file File to open
	 * @return Script created
	 */
	public function openOther(file:String):Null<LuaScript>
	{
		return LuaScript.create(file, this);
	}

	// #endregion
	// #region Close
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

		// Close self
		LuaCache.UnlinkScript(this.lua, this);
		LuaParenting.RemoveParent(this);
		llua.Lua.close(this.lua);
	}

	// #endregion
	// #region Data
	public var shared:custom.DataContainer;

	public static var global:custom.DataContainer = new custom.DataContainer(null);

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
		var scripts:Array<LuaScript> = LuaParenting.GetAll(callInChildren);
		var results:Array<Null<Dynamic>> = [];

		for (i in scripts)
		{
			var result:Null<Dynamic> = LuaHelper.call(i.lua, name, args);
			results.push(result);
		}

		return results;
	}

	// #endregion
}
