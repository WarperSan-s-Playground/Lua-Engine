package engine.hscript;

import helpers.FileHelper;
import crowplexus.iris.Iris;

class Loader extends Iris
{
	public function new(file:String)
	{
		super(null, {name: "hscript-iris", autoRun: false, autoPreset: true});

		this.scriptCode = FileHelper.ReadFile(file);
	}
}
