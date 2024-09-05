package lua_bridge;

import helpers.LogHelper;
import builtin.LogBuiltIn;
import builtin.AnimationBuiltIn;
import builtin.SpriteBuiltIn;
import flixel.FlxState;
import llua.LuaL;

class LuaScript
{
	private var lua:llua.State;

	public static function addScript(state:FlxState, file:String):LuaScript
	{
		return new LuaScript(state, file);
	}

	private function new(state:FlxState, file:String)
	{
		this.lua = LuaL.newstate();
		this.addBuiltIn(state);

		try
		{
			LuaL.openlibs(lua);
			LuaL.dofile(lua, file);
		}
		catch (e:Dynamic)
		{
			LogHelper.error('Error while loading the script \'$file\': $e');
		};
	}

	public function close()
	{
		llua.Lua.close(this.lua);
	}

	private function addBuiltIn(state:FlxState)
	{
		LuaHelper.addAll(lua, SpriteBuiltIn);
		LuaHelper.addAll(lua, AnimationBuiltIn);
		LuaHelper.addAll(lua, LogBuiltIn);
	}
}
