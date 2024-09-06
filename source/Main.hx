package;

import flixel.FlxG;
import openfl.display.FPS;
import builtin.LogBuiltIn;
import flixel.FlxGame;
import openfl.display.Sprite;

// MENUS TO ADD:
// - Title Menu
// - Main Menu (Story, Freeplay, Options, Advancements)
// - Freeplay Menu
// - Options Menu
class Main extends Sprite
{
	public inline function new()
	{
		super();

		haxe.Log.trace = LogBuiltIn.trace;

		// Set lua callback
		var luaCallback = cpp.Callable.fromStaticFunction(lua_bridge.LuaHelper.call);
		llua.Lua.set_callbacks_function(luaCallback);

		addChild(new FlxGame(0, 0, PlayState, 60, 60, true));

		var fps:FPS = new FPS(0, 0, 0xffffff);
		addChild(fps);

		FlxG.updateFramerate = 240;
		FlxG.drawFramerate = 240;
	}
}
