package;

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
	}
}
