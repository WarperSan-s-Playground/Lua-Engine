package lua_bridge;

/**
 * Class that manages the built-in for scripts
 */
class LuaImport
{
	/** Fetches all the imports */
	public static function getBuiltIn(addImportable:Bool):Array<Dynamic>
	{
		var methods:Array<Dynamic> = [];

		for (i in DEFAULT_BUILT_IN)
			methods.push(i);

		// Add importables if necessary
		if (addImportable)
		{
			for (i in IMPORTABLE_BUILT_IN)
				methods.push(i);
		}

		return methods;
	}

	/** All the files that are always imported to this script */
	private static var DEFAULT_BUILT_IN:Array<Dynamic> = [
		builtin.ScriptBuiltIn, 
		builtin.LogBuiltIn,
		builtin.ObjectBuiltIn
	];

	/** All the files that can be manually imported to this script */
	public static var IMPORTABLE_BUILT_IN:Array<Dynamic> = [
		builtin.RawBuiltIn,
		builtin.SpriteBuiltIn,
		builtin.FileBuiltIn,
		builtin.DataBuiltIn,
		builtin.StateBuiltIn,
		builtin.DebugBuiltIn,
		builtin.MusicBuiltIn,
		builtin.GroupBuiltIn
	];
}
