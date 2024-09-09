package helpers;

import lua_bridge.LuaScript;
import sys.FileSystem;

/** Class that creates the documentation for this engine to be compatible with https://github.com/Snirozu/Funkin-Script-AutoComplete */
class DocumentationHelper
{
	/** Prints the documentation of the built-in methods */
	public static function PrintDoc(file:String):Void
	{
		// Skip if already exist
		if (FileSystem.exists(file))
			return;

		var generated:Map<String, Dynamic> = [];
		var functions:Map<String, Dynamic> = [];

		for (t in LuaScript.BUILT_IN)
			for (i in ProcessClass(t))
				functions.set(i[0], i[1]);

		generated.set("functions", functions);

		// Write file
		var json = haxe.Json.stringify(generated, "\t");

		// Save the JSON to a file
		var file = sys.io.File.write(file);
		file.writeString(json);
		file.close();
	}

	/** Fetches the documentation for the given class */
	private static function ProcessClass(o:Dynamic):Array<Array<Dynamic>>
	{
		var __rtti = Reflect.field(o, "__rtti");

		// If invalid, skip
		if (__rtti == null)
        {
            LogHelper.error('The class \'$o\' is missing the rtti tag.');
			return [];
        }

		var classXML = Xml.parse(__rtti).firstElement();
		var methods:Array<Array<Dynamic>> = [];

		for (element in classXML.elements())
		{
			if (element.get("set") != "method")
				continue;

			methods.push([element.nodeName, ProcessMethod(element)]);
		}

		return methods;
	}

	/** Fetches the documentation for the given method */
	private static function ProcessMethod(element:Xml):Map<String, Dynamic>
	{
		var method:Map<String, Dynamic> = [];

		method.set("documentation", "No documentation given.");

		for (e in element.elements())
		{
			// If doc node
			if (e.nodeName == "haxe_doc")
			{
				var doc = e.firstChild().nodeValue;
				var r = ~/ ?(^|\n\t )*\*/g;
				method.set("documentation", r.replace(doc, ""));
				continue;
			}

			// name:Type = defaultValue
			if (e.nodeName == "f")
			{
				var args:String = "";
				var names = e.get("a").split(":");
				var values = e.get("v").split(":");

				var children = e.elements();
				var current = children.next();
				var index = 0;

				while (children.hasNext())
				{
					// Add name
					args += names[index];

					// Add type
					var type = current.get("path");

					if (type == null && current.nodeName == "d")
						type = "Dynamic";

					if (type != null)
						args += ":" + type;

					// Add value
					if (values[index] != "")
						args += " = " + values[index];

					current = children.next();
					index++;
				}

				// Set arguments
				method.set("args", args);

				// Set return from last item
				var type = current.get("path");

				if (type == null && current.nodeName == "d")
					type = "Dynamic";

				method.set("returns", type);
			}
		}

		return method;
	}
}
