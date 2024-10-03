package builtin;

import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import helpers.LuaHelper;

/** Class holding every built-in methods for animations */
@:rtti
class AnimationBuiltIn
{
	/**
	 * Adds an animation with the given prefix
	 * @param id Object to add to
	 * @param name Name of the animation
	 * @param prefix Prefix of the animation
	 * @param frameRate Frame rate of the animation
	 * @param looped Whether or not the animation is looped or just plays once
	 */
	public static function addAnimationByPrefix(id:Int = -1, name:String = "anim", prefix:String = "anim", frameRate:Int = 24, looped:Bool = true):Void
	{
		var sprite:FlxSprite = cast LuaHelper.getObject(id, "flixel.FlxSprite");

		// If controller invalid, skip
		if (sprite.animation == null)
			throw('The sprite does not have a ${FlxAnimationController}.');

		sprite.animation.addByPrefix(name, prefix, frameRate, looped);

		// Play as default
		if (sprite.animation.curAnim == null)
			sprite.animation.play(name);
	}

	/**
	 * Adds an animation with the given indices
	 * @param id Object to add to
	 * @param name Name of the animation
	 * @param prefix Prefix of the animation
	 * @param indices Indices of the animation
	 * @param frameRate Frame rate of the animation
	 * @param looped Whether or not the animation is looped or just plays once
	 */
	public static function addAnimationByIndices(id:Int = -1, name:String = "anim", prefix:String = "anim", indices:Array<Int> = null, frameRate:Int = 24,
			looped:Bool = true):Void
	{
		if (indices == null)
			indices = [];

		var sprite:FlxSprite = cast LuaHelper.getObject(id, "flixel.FlxSprite");

		// If controller invalid, skip
		if (sprite.animation == null)
			throw('The sprite does not have a ${FlxAnimationController}.');

		sprite.animation.addByIndices(name, prefix, indices, "", frameRate, looped);

		// Play as default
		if (sprite.animation.curAnim == null)
			sprite.animation.play(name);
	}
}
