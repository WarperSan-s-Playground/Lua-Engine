package helpers;

import engine.ScriptCache;
import engine.script.Script;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/** Handles files and paths */
class FileHelper
{
	/**
	 * Converts the path to an usable path
	 * @param file User given path
	 * @return Path to use or null if invalid
	 */
	public static function GetPath(file:Null<String>):Null<String>
	{
		// If file not given, skip
		if (file == null)
			return null;

		var fixed:String = ParsePath(file);

		// Normalize the path
		fixed = haxe.io.Path.normalize(fixed);

		// If path is an existing file, return path
		if (FileSystem.exists(fixed) && !FileSystem.isDirectory(fixed))
			return fixed;

		return null;
	}

	/**
	 * Parses the given path to the absolute path
	 * @param file User given path
	 * @return Path to use or null if invalid
	 */
	private static function ParsePath(file:String):String
	{
		var firstChar:String = file.charAt(0);

		// Search path from running script
		if (firstChar == '.')
		{
			var script:Null<Script> = ScriptCache.GetScript();

			// File from script => File from executable
			if (script != null)
				file = Path.directory(script.File) + "/" + file;
		}
		// Search path from root script
		else if (firstChar == '^')
		{
			var script:Null<Script> = ScriptCache.GetScript();

			// File from script => File from executable
			if (script != null)
			{
				var parent:Null<Script> = script;
				while (parent != null)
				{
					parent = script.Parent;

					if (parent != null)
						script = parent;
				}

				file = Path.directory(script.File) + file.substring(1);
			}
		}
		// Search path from the executable
		else if (firstChar == '~')
		{
			file = '.' + file.substring(1);
		}
		// Search path from either script or executable
		else
			file = GetPath('./' + file) ?? GetPath('~/' + file);

		return file;
	}

	/**
	 * Reads the content of the given file
	 * @param file File to read from
	 * @return Content read or null if invalid
	 */
	public static function ReadFile(file:String):Null<String>
	{
		file = GetPath(file);

		if (file == null)
			return null;

		return File.getContent(file);
	}
}
