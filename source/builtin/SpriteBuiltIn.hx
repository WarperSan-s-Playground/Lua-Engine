package builtin;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import helpers.FileHelper;
import helpers.LuaHelper;

/** Class holding every built-in methods for sprites */
@:rtti
class SpriteBuiltIn
{
	/**
	 * Creates a new sprite for this state
	 * @return ID of the sprite
	 */
	public static function makeSprite(x:Float = 0, y:Float = 0):Int
	{
		var state:FlxState = FlxG.state;

		// If state invalid, skip
		if (state == null)
			throw('Invalid state.');

		var sprite:FlxSprite = new FlxSprite();
		sprite.x = x;
		sprite.y = y;
		sprite.antialiasing = true;
		state.add(sprite);

		return sprite.ID;
	}

	/**
	 * Removes a sprite with the given ID
	 * @param id ID of the sprite to remove
	 * @param forceDestroy Force the game to destroy the sprite
	 */
	public static function removeSprite(id:Int = -1, forceDestroy:Bool = false):Void
	{
		var sprite:FlxSprite = cast LuaHelper.getObject(id);

		if (forceDestroy || sprite.container == null)
			sprite.destroy();
		else
			sprite.kill();
	}

	/**
	 * Loads the given image to the given sprite
	 * @param id Sprite to load to
	 * @param path Image to load from
	 * @param xml XML file to load frames from
	 */
	public static function loadGraphic(id:Int = -1, path:String = "", xml:Null<String> = null):Void
	{
		var sprite:FlxSprite = cast LuaHelper.getObject(id);

		// Check if path valid
		var fixedPath:String = helpers.FileHelper.GetPath(path);

		if (fixedPath == null)
			throw('The path \'$path\' is invalid.');

		// Load grahic
		var graphic:Null<flixel.graphics.FlxGraphic> = helpers.FileHelper.LoadGraphic(fixedPath);

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

	/**
	 * Makes a graphic to the given sprite
	 * @param id Sprite to make to
	 * @param width Width of the graphic
	 * @param height Height of the graphic
	 * @param color Color of the graphic
	 */
	public static function makeGraphic(id:Int = -1, width:Int = 0, height:Int = 0, color:Null<String> = null):Void
	{
		var sprite:FlxSprite = cast LuaHelper.getObject(id);

		// Clamp width
		if (width < 0)
			width = 0;

		// Clamp height
		if (height < 0)
			height = 0;

		// Parse color
		if (color == null)
			color = "#FFFFFF";

		var clr:Null<FlxColor> = FlxColor.fromString(color);

		if (clr == null)
			throw('Could not parse the color \'$color\'.');

		// Make graphic
		sprite.makeGraphic(width, height, clr);
	}
}
