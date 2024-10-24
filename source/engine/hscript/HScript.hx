package engine.hscript;

import engine.script.Script;
import crowplexus.iris.Iris;

class HScript extends Script
{
	public function new(file:String, parent:Null<Script>)
	{
		super(file, parent);
		this.loader = new Loader(file);
	}

	private final loader:Loader;

	public inline function execute():Void
		this.loader.execute();

	private inline function set(name:String, value:Dynamic):Void
		this.loader.set(name, value, true);

	public function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		var value:Null<IrisCall> = this.loader.call(name, args);

		if (value == null)
			return null;

		return value.returnValue;
	}

	private inline function destroy():Void
		this.loader.destroy();
}
