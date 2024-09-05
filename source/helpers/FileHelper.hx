package helpers;

import haxe.io.Path;
import sys.io.File;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;

class FileHelper
{
	private static var loadedGraphics:haxe.ds.Map<String, FlxGraphic> = new haxe.ds.Map<String, FlxGraphic>();

	/**
	 * Converts the path to an usable path
	 * @param file User given path
	 * @return Null<String> Path to use or null if invalid
	 */
	public static function GetPath(file:String):Null<String>
	{
		// Path from script
		if (file.charAt(0) == '.')
		{
			// ../Images/gfDanceTitle.png => ~/source/States/Title/Scripts/../Images/gfDanceTitle.png
			// File from executable => File from script
		}

		// Path from executable
		if (file.charAt(0) == '~')
			file = '.' + file.substring(1);

		//if (true)
		//	file = Path.normalize(file);

		LogHelper.info(file);

		// If path is an existing file, return path
		if (FileSystem.exists(file) && !FileSystem.isDirectory(file))
			return file;

		return null;
	}

	/**
	 * Reads the content of the given file
	 * @param file File to read from
	 * @return Null<String> Content read or null if invalid
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
	 * @return Null<FlxGraphic> Graphic for this file
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
	 * @return Null<flixel.graphics.frames.FlxFramesCollection> Animation for this file
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
