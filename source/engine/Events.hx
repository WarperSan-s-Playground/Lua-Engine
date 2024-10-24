package engine;

import engine.script.Message;
import helpers.LogHelper;
import engine.script.Script;

/** Class containing all the events for a script **/
class Events
{
	private var script(default, null):Script;

	public function new(script:Script)
	{
		this.script = script;
	}

	/**
	 * Calls the method with the given name with the given arguments
	 * @param name Name of the method to call
	 * @param args Arguments of the call
	 * @param callInChildren Should be call in the children
	 * @return Result for each script
	 */
	public function callMethod(name:String, args:Array<Dynamic>, callInChildren:Bool):Map<String, Null<Dynamic>>
	{
		// If the script has ERRORED, skip all call
		if (this.script.State == ERRORED)
			return [];

		var results:Map<String, Null<Dynamic>> = [];

		// Call in self
		var local = null;
		try
		{
			local = this.script.callMethod(name, args);
		}
		catch (e:String)
		{
			this.script.State = ERRORED;
			LogHelper.error('Error while invoking \'$name\' in \'${this.script.File}\': $e');
			local = error(e);
		}
		results.set(this.script.File, local);

		if (!callInChildren)
			return results;

		for (child in this.script.Children)
		{
			var childResults:Map<String, Null<Dynamic>> = child.Events.callMethod(name, args, true);

			for (r in childResults)
				results.set(child.File, r);
		}

		return results;
	}

	public inline function OnCreate(hasParent:Bool):Void
		this.callMethod("OnCreate", [hasParent], false);

	public inline function OnDestroy():Void
		this.callMethod("OnDestroy", [], false);

	public inline function OnUpdate(elapsed:Float):Void
		this.callMethod("OnUpdate", [elapsed], true);
}
