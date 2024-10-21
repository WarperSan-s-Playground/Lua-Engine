package engine;

import engine.script.Script;

/** Class containing all the events for a script **/
class Events
{
	private var script(default, null):Script;

	public function new(script:Script)
	{
		this.script = script;
	}

	public function OnCreate(hasParent:Bool):Void
	{
		this.script.call("OnCreate", [hasParent], false);
	}

	public function OnDestroy():Void
	{
		this.script.call("OnDestroy", [], false);
	}

	public function OnUpdate(elapsed:Float):Void
	{
		this.script.call("OnUpdate", [elapsed], true);
	}
}
