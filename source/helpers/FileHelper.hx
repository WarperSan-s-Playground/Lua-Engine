package helpers;

import lua_bridge.LuaParenting;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import lua_bridge.LuaCache;
import lua_bridge.LuaScript;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

class FileHelper
{
	private static var loadedGraphics:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	private static var loadedSounds:Map<String, Sound> = new Map<String, Sound>();

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
			var script:Null<LuaScript> = LuaCache.GetScript();

			// File from script => File from executable
			if (script != null)
				file = Path.directory(script.file) + "/" + file;
		}
		// Search path from root script
		else if (firstChar == '^')
		{
			var script:Null<LuaScript> = LuaCache.GetScript();

			// File from script => File from executable
			if (script != null)
			{
				var parent:Null<LuaScript> = script;
				while (parent != null)
				{
					parent = LuaParenting.GetParent(script);

					if (parent != null)
						script = parent;
				}

				file = Path.directory(script.file) + file.substring(1);
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
	 * Loads the graphic from the given file
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
	 * Loads the frames from the given file
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

	/**
	 * Loads the sound from the given file
	 * @param file File of the resource
	 * @return Sound for this file
	 */
	public static function LoadSound(file:String):Null<Sound>
	{
		// If cached, return value
		if (loadedSounds.exists(file))
			return loadedSounds.get(file);

		var data:Sound = Sound.fromFile(file);

		// If data invalid, skip
		if (data == null)
			return null;

		// Add to cache
		loadedSounds.set(file, data);

		return data;
	}
}
