package;

import engine.lua.LuaScript;
import objects.FPSCounter;
import sys.FileSystem;
import sys.thread.Thread;
import helpers.LogHelper;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.ScriptState;
import flixel.FlxG;

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
		var luaCallback = cpp.Callable.fromStaticFunction(LuaScript.callback);
		llua.Lua.set_callbacks_function(luaCallback);

		// Create starting state
		addChild(new FlxGame(0, 0, () -> new ScriptState("~/start.lua"), 60, 60, true));

		// FPS counter
		var fps:FPSCounter = new FPSCounter(10, 3, 0xFFFFFF);
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
