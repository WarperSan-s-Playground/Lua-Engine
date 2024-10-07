package states;

import engine.Script;

class ScriptState extends flixel.FlxState
{
	private var root:Script;
	private var file:String;

	public function new(file:String)
	{
		super();
		this.file = file;
	}

	override function create()
	{
		root = Script.openFile(this.file, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		root.call("OnUpdate", [elapsed], true);
	}

	override function destroy()
	{
		super.destroy();
		root.close();
	}
}
