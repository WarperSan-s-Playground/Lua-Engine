package helpers;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxBasic;

/** Handles the FlxBasic */
class FlxBasicHelper
{
	private static var cachedObjects:Map<Int, FlxBasic> = new Map<Int, FlxBasic>();

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

		var basic:Null<FlxBasic> = null;

		if (cachedObjects.exists(id))
		{
			var cached:Null<FlxBasic> = cachedObjects.get(id);

			if (Std.isOfType(cached, type))
				basic = cached;
		}
		else
		{
			LogHelper.verbose('Manually searches for a \'$type\' with the ID \'$id\'.');
			basic = FlxG.state.getFirst((b:FlxBasic) ->
			{
				return b.ID == id && Std.isOfType(b, type);
			});
		}

		// If basic not found, skip
		if (basic == null)
			throw('Could not find an instance of \'$type\' with the ID \'$id\'.');

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
		cachedObjects.set(basic.ID, basic);

		LogHelper.verbose('Added a \'${Type.getClassName(Type.getClass(basic))}\' with the ID \'${basic.ID}\'.');

		return basic.ID;
	}

	/**
	 * Removes the element with the given ID
	 * @param id ID of the element to destroy
	 */
	public static function remove(id:Int):Void
	{
		var obj:Null<FlxBasic> = null;

		if (cachedObjects.exists(id))
		{
			obj = cachedObjects.get(id);
			cachedObjects.remove(id);
		}
		else
			obj = FlxBasicHelper.getObject(id, FlxBasic);

		if (obj.container != null)
			obj.container.remove(obj, true);
		obj.destroy();

		LogHelper.verbose('Removed a \'${Type.getClassName(Type.getClass(obj))}\' with the ID \'${id}\'.');
	}
}
