package helpers;

import haxe.Constraints.IMap;
import interfaces.IMeasurable;
import engine.ScriptParenting;
import engine.Script;

/** Handles debug methods */
class DebugHelper
{
	public static function printState():String
	{
		// Roots
		// ├── Syllabaries (Mem: ?KB | Status: O)
		// │   ├── Hiragana
		// │   ├── Katakana
		// │   └── Cherokee
		// └── Logographic Scripts

		var roots:Array<Script> = ScriptParenting.GetAll(false);
		var result:String = "";

		result += "Roots\n";

		var i:Int = 0;
		while (i < roots.length)
		{
			result += printScript(roots[i], i == roots.length - 1, 0);
			i++;
		}

		return result;
	}

	private static function printScript(script:Script, isLast:Bool, level:Int):String
	{
		var result:String = "";

		var status:String = "";
		switch (script.State)
		{
			case Open:
				status = "O";
			case Running:
				status = "R";
			case Errored:
				status = "E";
			case Closed:
				status = "C";
			default:
				status = "?";
		}
		var memory:String = Std.string(script.getSize()) + "B";

		// Add offset
		for (i in 0...level)
			result += "   ";

		// Use correct corner
		if (isLast)
			result += "└";
		else
			result += "├";

		result += "── ";
		result += script.File;
		result += ' (Mem: $memory | Status: $status)';
		result += "\n";

		var children = script.Children;
		var i:Int = 0;
		while (i < children.length)
		{
			if (isLast)
				result += " ";
			else
				result += "│";

			result += printScript(children[i], i == children.length - 1, level + 1);

			i++;
		}

		return result;
	}

	public static function getSize(value:Dynamic):Int
	{
        // Measure custom
		if (Std.isOfType(value, IMeasurable))
			return cast(value, IMeasurable).getSize();

		// Measure bool
		if (Std.isOfType(value, Bool))
			return 1;

		// Measure int
		if (Std.isOfType(value, Int))
			return 4;

		// Measure float (here, it's double)
		if (Std.isOfType(value, Float))
			return 8;

		// Measure string
		if (Std.isOfType(value, String))
        {
            var length = cast(value, String).length;
            return 4 + length * 2; // 4 bytes for length + 2 bytes per char for UTF-16
        }

		// Measure map
		if (Std.isOfType(value, IMap))
		{
			var map:IMap<Dynamic, Dynamic> = cast value;
			var size = 4; // Reference

			for (i in map.keys())
			{
				size += getSize(i);
				size += getSize(map.get(i));
			}

			return size;
		}

		var size = 4;
		for (key in Reflect.fields(value))
			size += getSize(Reflect.field(value, key));
		return size;
	}
}
