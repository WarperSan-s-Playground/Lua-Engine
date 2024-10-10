package;

import sys.FileSystem;
import sys.thread.Thread;
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

		// FPS counter
		var fps:FPS = new FPS(0, 0, 0xffffff);
		addChild(fps);

		// Target FPS
		FlxG.updateFramerate = 250;
		FlxG.drawFramerate = 250;

		// If documentation doesn't exist, create
		var docFile:String = "source/LuaEngine.json";
		if (!FileSystem.exists(docFile))
			Thread.create(() -> helpers.DocumentationHelper.PrintDoc(docFile));
	}
}
