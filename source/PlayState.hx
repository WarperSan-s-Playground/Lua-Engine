package;

using lua_bridge.LuaScript;

import lua_bridge.LuaScript;

class PlayState extends flixel.FlxState
{
	override public function create()
	{
		super.create();

		flixel.FlxG.autoPause = false;

		var script:LuaScript = LuaScript.openFile("source/States/Title/Scripts/script.lua");
		script.close();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
