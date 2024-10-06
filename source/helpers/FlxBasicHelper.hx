package helpers;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxBasic;

class FlxBasicHelper
{
	/**
	 * Fetches the object with the given ID
	 * @param id ID of the object
	 * @param type Type of the object
	 * @return Object fetched
	 */
	public static function getObject<T>(id:Int, type:Class<Dynamic>):T
	{
		// If id invalid, skip
		if (id < 0)
			throw('The ID \'$id\' is not valid.');

		// If type invalid, skip
		if (type == null)
			throw('No class was found with the name \'$type\'.');

		var state:flixel.FlxState = flixel.FlxG.state;

		// If state invalid, skip
		if (state == null)
			throw('Invalid state.');

		var basic:Null<flixel.FlxBasic> = state.getFirst((b:flixel.FlxBasic) ->
		{
			return b.ID == id && Std.isOfType(b, type);
		});

		// If basic not found, skip
		if (basic == null)
			throw('Could not find a $type with the ID \'$id\'.');

        var result:T = cast basic;
		return result;
	}

	/**
	 * Adds the given element to the current game state
	 * @param basic Element to add
	 * @return Unique ID of the added element
	 */
	public static function add(basic:FlxBasic):Int
	{
		var state:FlxState = FlxG.state;

		// If state invalid, skip
		if (state == null)
			throw('Invalid state.');

		state.add(basic);

		return basic.ID;
	}
}
