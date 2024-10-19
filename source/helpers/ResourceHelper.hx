package helpers;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.media.Sound;
import haxe.io.Path;
import haxe.ds.StringMap;

/** Handles the caching of resources */
class ResourceHelper
{
	public static var loaded(default, null):StringMap<Dynamic> = new StringMap<Dynamic>();

	/**
	 * Loads and cache the resource at the given path
	 * @param path Path to the resource
	 * @return Object loaded
	 */
	public static function Load(path:String):Null<Dynamic>
	{
		var fixed:Null<String> = FileHelper.GetPath(path);

		if (fixed == null)
			throw('Could not find the resource at \'$path\'.');

		// If already loaded, return cached
		if (loaded.exists(fixed))
			return loaded.get(fixed);

		var extension:String = Path.extension(fixed);
		var data:Null<Dynamic> = null;

		LogHelper.verbose('Starting to load the resource \'$fixed\'.');

		switch (extension)
		{
			// Sounds
			case "mp3", "ogg", "wav":
				data = LoadSound(fixed);
			// Animations
			case "xml":
				data = LoadAnimation(fixed);
			// Sprites
			case "png", "jpg", "jpeg":
				data = LoadSprite(fixed);
			default:
				throw('The extension \'$extension\' is not a supported file.');
		}

		if (data != null)
			LogHelper.verbose('Finished to load the resource \'$fixed\'.');
		else
			LogHelper.verbose('Failed to load the resource \'$fixed\'.');

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
		var fixed:Null<String> = FileHelper.GetPath(path);

		if (fixed == null)
			throw('Could not find the resource at \'$path\'.');

		// If not loaded, skip
		if (!loaded.exists(fixed))
			return true;

		LogHelper.verbose('Starting to release the resource \'$fixed\'.');
		var data = loaded.get(fixed);
		loaded.remove(fixed);
		var succeed:Bool;

		switch (data)
		{
			case FlxGraphic:
				succeed = ReleaseSprite(data);
			case Sound:
				succeed = ReleaseSound(data);
			default:
				succeed = true;
		}

		if (succeed)
			LogHelper.verbose('Finished to release the resource \'$fixed\'.');
		else
			LogHelper.verbose('Failedto release the resource \'$fixed\'.');

		return succeed;
	}

	// #region Sound

	private inline static function LoadSound(file:String):Null<Sound>
		return Sound.fromFile(file);

	private static function ReleaseSound(sound:Sound):Bool
	{
		if (sound.isBuffering)
			sound.close();
		return true;
	}

	// #endregion
	// #region Animation

	private inline static function LoadAnimation(file:String):Null<String>
		return FileHelper.ReadFile(file);

	// #endregion
	// #region Sprite

	private static function LoadSprite(file:String):Null<FlxGraphic>
	{
		var bit:BitmapData = BitmapData.fromFile(file);

		// If invalid, skips
		if (bit == null)
			return null;

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bit, false, file);

		// If invalid, skip
		if (graphic == null)
			return null;

		graphic.persist = true;
		return graphic;
	}

	private static function ReleaseSprite(graphic:FlxGraphic):Bool
	{
		graphic.persist = false;
		FlxG.bitmap.remove(graphic);
		return true;
	}

	// #endregion
}
