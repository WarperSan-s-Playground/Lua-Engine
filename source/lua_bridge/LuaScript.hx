package lua_bridge;

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
	private static var rootScripts:Array<LuaScript> = new Array<LuaScript>();

	private var childScripts:Array<LuaScript> = new Array<LuaScript>();

	private var lua:llua.State;

	public var file:String;
	public var isClosed:Bool = false;

	private function new(file:String)
	{
		// Check if file exists
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.file = fixed;

		this.lua = LuaL.newstate();
		this.addBuiltIn();
		this.execute();
	}

	/** Adds every built-in methods to this script */
	private function addBuiltIn()
	{
		LuaHelper.addAll(this.lua, SpriteBuiltIn);
		LuaHelper.addAll(this.lua, AnimationBuiltIn);
		LuaHelper.addAll(this.lua, LogBuiltIn);
		LuaHelper.addAll(this.lua, FileBuiltIn);
	}

	/** Closes this script and the related scripts */
	public function close()
	{
		// If already closed, skip
		if (this.isClosed)
			return;

		this.isClosed = true;

		// Close children
		for (child in this.childScripts)
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
	 * @return Created script
	 */
	private static function create(file:String):Null<LuaScript>
	{
		// Create script
		var script:Null<LuaScript> = null;

		try
		{
			script = new LuaScript(file);
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
	 * @return Script created
	 */
	public static function openFile(file:String):Null<LuaScript>
	{
		var script:Null<LuaScript> = LuaScript.create(file);

		if (script != null)
			rootScripts.push(script);

		return script;
	}

	/**
	 * Opens another file that is related to this one. If this script closes, the other script closes too.
	 * @param file File to open
	 * @return Script created
	 */
	public function openOther(file:String):Null<LuaScript>
	{
		var script:Null<LuaScript> = LuaScript.create(file);

		// Attach to parent
		if (script != null)
			this.childScripts.push(script);

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
}
