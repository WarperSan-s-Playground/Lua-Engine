package builtin;

import helpers.FlxBasicHelper;
import flixel.FlxSprite;
import helpers.FileHelper;

/** Class holding every built-in methods for sprites */
@:rtti
class SpriteBuiltIn
{
	/**
	 * Loads the given image to the given sprite
	 * @param id Sprite to load to
	 * @param path Image to load from
	 * @param xml XML file to load frames from
	 */
	public static function loadGraphic(id:Int = -1, path:String = "", xml:Null<String> = null):Void
	{
		var sprite:FlxSprite = cast FlxBasicHelper.getObject(id, FlxSprite);

		// Check if path valid
		var fixedPath:String = FileHelper.GetPath(path);

		if (fixedPath == null)
			throw('The path \'$path\' is invalid.');

		// Load grahic
		var graphic:Null<flixel.graphics.FlxGraphic> = FileHelper.LoadGraphic(fixedPath);

		if (graphic == null)
			throw('Could not create the request graphic.');

		sprite.loadGraphic(graphic, true);

		if (xml == null)
		{
			var path:Array<String> = fixedPath.split('.');
			path[path.length - 1] = "xml";
			xml = path.join('.');
		}

		sprite.frames = FileHelper.LoadFrames(sprite.graphic, xml);
	}
}
