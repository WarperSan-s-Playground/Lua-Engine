package states;

import lua_bridge.LuaScript;

class LuaState extends flixel.FlxState
{
	private var root:LuaScript;
	private var file:String;

	public function new(file:String)
	{
		super();
		this.file = file;
	}

	override function create()
	{
		root = LuaScript.openFile(this.file, true);
		try {
			root.call("OnCreate", [], true);
		}
		catch (e:String)
		{
			trace(e);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		root.call("OnUpdate", [elapsed], true);
	}

	override function destroy()
	{
		super.destroy();

		root.call("OnDestroy", [], true);
		root.close();
	}
}
