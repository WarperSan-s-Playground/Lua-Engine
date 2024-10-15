package helpers;

import flixel.FlxG;
import haxe.ds.StringMap;
import engine.ScriptCache;
import engine.Script;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

class FileHelper
{
	private static var loaded:StringMap<Dynamic> = new StringMap<Dynamic>();
	private static var loadedGraphics:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	/**
	 * Converts the path to an usable path
	 * @param file User given path
	 * @return Path to use or null if invalid
	 */
	public static function GetPath(file:Null<String>):Null<String>
	{
		file = ParsePath(file);

		// If file not given, skip
		if (file == null)
			return null;

		// Normalize the path
		file = haxe.io.Path.normalize(file);

		// If path is an existing file, return path
		if (FileSystem.exists(file) && !FileSystem.isDirectory(file))
			return file;

		return null;
	}

	/**
	 * Parses the given path to the absolute path
	 * @param file User given path
	 * @return Path to use or null if invalid
	 */
	public static function ParsePath(file:Null<String>):Null<String>
	{
		// If file not given, skip
		if (file == null)
			return null;

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

	/**
	 * Loads and cache the resource at the given path
	 * @param path Path to the resource
	 * @return Object loaded
	 */
	public static function Load(path:String):Null<Dynamic>
	{
		var fixed:Null<String> = GetPath(path);

		if (fixed == null)
			throw('Could not find the resource at \'$path\'.');

		// If already loaded, return cached
		if (loaded.exists(fixed))
			return loaded.get(fixed);

		var extension:String = Path.extension(fixed);
		var data:Null<Dynamic> = null;

		switch (extension)
		{
			// Sounds
			case "mp3", "ogg", "wav":
				data = Sound.fromFile(fixed);
			// Animations
			case "xml":
				data = ReadFile(fixed);
			// Sprites
			case "png", "jpg", "jpeg":
				var bit:BitmapData = BitmapData.fromFile(fixed);

				// If valid
				if (bit != null)
				{
					var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bit, false, fixed);

					// If loaded
					if (graphic != null)
					{
						data = graphic;
						graphic.persist = true;
					}
				}
			default:
				throw('The extension \'$extension\' is not a supported file.');
		}

		if (data == null)
			return null;

		loaded.set(fixed, data);
		return data;
	}

	/**
	 * Releases the resource at the given path
	 * @param path Path to the resource 
	 * @return Succeed to release the resource
	 */
	public static function Release(path:String):Bool
	{
		var fixed:Null<String> = GetPath(path);

		if (fixed == null)
			throw('Could not find the resource at \'$path\'.');

		// If not loaded, skip
		if (!loaded.exists(fixed))
			return true;

		var data = loaded.get(fixed);
		loaded.remove(fixed);

		// Release graphic
		if (Std.isOfType(data, FlxGraphic))
		{
			var g = cast(data, FlxGraphic);
			g.persist = false;
			FlxG.bitmap.remove(g);
		}

		return true;
	}
}
