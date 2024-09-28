package helpers;

import lua_bridge.LuaImport;
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

		for (t in LuaImport.getBuiltIn(true))
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
				method.set("documentation", ProcessHaxeDoc(e));
				continue;
			}

			// name:Type = defaultValue
			if (e.nodeName == "f")
			{
				var results = ProcessArguments(e);

				// Set arguments
				method.set("args", results[0]);
				method.set("returns", ProcessReturn(results[1]));
			}
		}

		return method;
	}

	/** Process the haxe documentation */
	private static function ProcessHaxeDoc(e:Xml):String
	{
		var doc = e.firstChild().nodeValue;

		doc = ~/ ?\* /g.replace(doc, ""); // Remove /*
		doc = ~/(?<=@param )(\w*)/g.replace(doc, "`$1`"); // Put the arguments inside a fancy tag
		doc = ~/\n\t/g.replace(doc, "\n\r"); // Reformat new line
		doc = ~/@param /g.replace(doc, "* "); // Remove @param tag

		return doc;
	}

	/** Process the arguments */
	private static function ProcessArguments(e:Xml):Array<Dynamic>
	{
		var args:String = "";
		var names = e.get("a").split(":");
		var values = e.get("v").split(":");

		var elems = e.elements();
		var current = elems.next();
		var index = 0;

		while (elems.hasNext())
		{
			if (index > 0)
				args += ", ";

			// Add name
			args += names[index].substring(1);

			// Add type
			var type = current.get("path");

			if (type == null && current.nodeName == "d")
				type = "Dynamic";

			if (type != null)
				args += ":" + type;

			// Add value
			if (values[index] != "")
				args += " = " + values[index];

			current = elems.next();
			index++;
		}

		return [args, current];
	}

	/** Process the return documentation */
	private static function ProcessReturn(e:Xml):String
	{
		// Set return from last item
		var type = e.get("path");
		var s = Type.getClassName(lua_bridge.LuaMessage).split(".").pop();

		if (type == null && e.nodeName == "d")
			type = "Dynamic";

		if (type != "Void")
			s += '<$type>';

		return s;
	}
}
