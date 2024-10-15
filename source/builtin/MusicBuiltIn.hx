package builtin;

import flixel.FlxG;

@:rtti
class MusicBuiltIn
{
	/**
	 * Plays the given music
	 * @param path Path of the music
	 * @param overrideMusic Determines if this will overrride the current music
	 * @param volume How loud the sound should be, from 0 to 1
	 * @param looped Whether to loop this music
	 */
	public static function playMusic(path:String = "", overrideMusic:Bool = true, volume:Float = 1.0, looped:Bool = true):Void
	{
		if (FlxG.sound.music != null && !overrideMusic)
			throw('Tried to play a music while another music was playing.');
		
		// Load sound
		var data:Null<Dynamic> = helpers.FileHelper.Load(path);

		if (data == null)
			throw('Could not play the request music.');

		// Play music
		FlxG.sound.playMusic(data, volume, looped);
	}
}
