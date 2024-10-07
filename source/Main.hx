package;

import engine.LuaScript;
import helpers.LogHelper;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.ScriptState;

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

		haxe.Log.trace = function(value:Dynamic, ?infos:Null<haxe.PosInfos>)
		{
			LogHelper.debug(value);
		};

		// Set lua callback
		var luaCallback = cpp.Callable.fromStaticFunction(helpers.LuaHelper.callback);
		llua.Lua.set_callbacks_function(luaCallback);

		// Create starting state
		addChild(new FlxGame(0, 0, () -> new ScriptState("~/start.lua"), 60, 60, true));

		var fps:FPS = new FPS(0, 0, 0xffffff);
		addChild(fps);

		FlxG.updateFramerate = 250;
		FlxG.drawFramerate = 250;

		// Print doc if necessary
		helpers.DocumentationHelper.PrintDoc("source/LuaEngine.json");
	}
}
