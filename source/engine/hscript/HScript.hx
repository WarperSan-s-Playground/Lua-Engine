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

	override inline function importMethod(name:String, callback:Dynamic)
		this.loader.set(name, callback, true);

	public function execute()
	{
		this.loader.execute();
	}

	function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>
	{
		var value:Null<IrisCall> = this.loader.call(name, args);

		if (value == null)
			return null;

		return value.returnValue;
	}

	function destroy()
	{
		this.loader.destroy();
	}
}
