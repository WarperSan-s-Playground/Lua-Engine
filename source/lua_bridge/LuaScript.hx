package lua_bridge;

import llua.State;
import llua.LuaL;
import helpers.LogHelper;
import builtin.LogBuiltIn;
import builtin.AnimationBuiltIn;
import builtin.SpriteBuiltIn;
import flixel.FlxState;

class LuaScript
{
	private var lua:llua.State;
	public var file:String;

	public static function addScript(state:FlxState, file:String):LuaScript
	{
		return new LuaScript(state, file);
	}

	private function new(state:FlxState, file:String)
	{
		this.lua = LuaL.newstate();
		this.file = file;
		this.addBuiltIn(state);
		
		try
		{
			LuaL.openlibs(lua);
			LuaCache.LinkScript(this.lua, this);
			LuaL.dofile(lua, file);
		}
		catch (e:Dynamic)
		{
			LogHelper.error('Error while loading the script \'$file\': $e');
		};
	}

	public function close()
	{
		LuaCache.UnlinkScript(this.lua, this);
		llua.Lua.close(this.lua);
	}

	private function addBuiltIn(state:FlxState)
	{
		LuaHelper.addAll(this.lua, SpriteBuiltIn);
		LuaHelper.addAll(this.lua, AnimationBuiltIn);
		LuaHelper.addAll(this.lua, LogBuiltIn);
	}
}
