package helpers;

import lua_bridge.LuaScript;
import lua_bridge.LuaCache;
import haxe.io.Path;
import sys.io.File;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;

class FileHelper
{
	private static var loadedGraphics:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

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

		// Path from script
		if (file.charAt(0) == '.')
		{
			var script:Null<LuaScript> = LuaCache.GetScript();

			// File from script => File from executable 
			if (script != null)
				file = Path.directory(script.file) + "/" + file;
		}

		// Path from executable
		if (file.charAt(0) == '~')
			file = '.' + file.substring(1);

		// Normalize the path
		file = haxe.io.Path.normalize(file);

		// If path is an existing file, return path
		if (FileSystem.exists(file) && !FileSystem.isDirectory(file))
			return file;

		return null;
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
	 * Creates a graphic from the given file
	 * @param file File of the resource
	 * @return Graphic for this file
	 */
	public static function LoadGraphic(file:String):Null<FlxGraphic>
	{
		// If cached, return value
		if (loadedGraphics.exists(file))
			return loadedGraphics.get(file);

		var data:BitmapData = BitmapData.fromFile(file);

		// If data invalid, skip
		if (data == null)
			return null;

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(data, false, file);

		// If graphic invalid, skip
		if (graphic == null)
			return null;

		// Add to cache
		loadedGraphics.set(file, graphic);
		graphic.persist = true;

		return graphic;
	}

	/**
	 * Creates frames from the given file
	 * @param graphic Graphic to add the animation to
	 * @param file File of the resource
	 * @return Animation for this file
	 */
	public static function LoadFrames(graphic:flixel.graphics.FlxGraphic, file:String):Null<flixel.graphics.frames.FlxFramesCollection>
	{
		// If graphic invalid, skip
		if (graphic == null)
			return null;

		// If content not found, skip
		var content:Null<String> = ReadFile(file);

		if (content == null)
			return null;

		return flixel.graphics.frames.FlxAtlasFrames.fromSparrow(graphic, content);
	}
}
