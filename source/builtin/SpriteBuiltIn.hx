package builtin;

import helpers.ResourceHelper;
import helpers.FlxBasicHelper;
import flixel.FlxSprite;

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

		// Load grahic
		var graphic:Null<flixel.graphics.FlxGraphic> = ResourceHelper.Load(path);

		if (graphic == null)
			throw('Could not create the request graphic.');

		sprite.loadGraphic(graphic, xml != null);

		// Load animations
		if (xml != null)
		{
			var xmlContent:Null<Dynamic> = ResourceHelper.Load(xml);

			if (xmlContent != null)
				sprite.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(graphic, xmlContent);
		}
	}
}
