package builtin;

import helpers.FileHelper;
import lua_bridge.LuaHelper;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * Class holding every built-in methods for sprites
 */
class SpriteBuiltIn
{
	/**
	 * Creates a new sprite for this state
	 * @return ID of the sprite
	 */
	public static function makeSprite(x:Float = 0, y:Float = 0):Dynamic
	{
		var state:FlxState = FlxG.state;

		// If state invalid, skip
		if (state == null)
			throw('Invalid state.');

		var sprite:FlxSprite = new FlxSprite();
		sprite.x = x;
		sprite.y = y;
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
			throw('The path \'${path}\' is invalid.');

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
}
