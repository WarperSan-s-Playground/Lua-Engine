package builtin;

import haxe.Json;
import haxe.io.Path;
import helpers.FileHelper;

/** Class holding every built-in methods for files */
@:rtti
class FileBuiltIn
{
	/**
	 * Parses the given file as JSON
	 * @param file File to parse
	 * @return Object created
	 */
	public static function fromJSON(file:Null<String> = null):Dynamic
	{
		var fixed:String = FileHelper.GetPath(file);

		// File not found
		if (fixed == null)
			throw('Could not find a file at \'$file\'.');

		// Check for extension
		var extension:Null<String> = Path.extension(fixed);
		if (extension != "json")
			throw('Expected a JSON file. Received a \'$extension\' file.');

		// Read content
		var content:String = FileHelper.ReadFile(fixed);
		if (content == null)
			throw('Failed to load the file \'$fixed\'.');

		return Json.parse(content);
	}

	/**
	 * Converts the path to an usable path
	 * @param file User given path
	 * @return Null<String> Path to use or null if invalid
	 */
	public static function getPath(file:Null<String> = null):Null<String>
	{
		return FileHelper.GetPath(file);
	}
}
