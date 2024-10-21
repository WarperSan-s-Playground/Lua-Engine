package states;

import engine.script.Script;

/** State that is created from a script */
class ScriptState extends flixel.FlxState
{
	private var instance:Script;
	private var file:String;

	public function new(file:String)
	{
		super();
		this.file = file;
	}

	public override function create()
	{
		instance = Script.openFile(this.file, null);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		instance.Events.OnUpdate(elapsed);
	}

	override function destroy()
	{
		super.destroy();
		instance.close();
	}
}
