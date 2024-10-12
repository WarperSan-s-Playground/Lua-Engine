package builtin;

import haxe.ds.StringMap;
import flixel.FlxBasic;
import helpers.FlxBasicHelper;

@:rtti
class ObjectBuiltIn
{
	/**
	 * Submits the given changes to the instance with the given ID
	 * @param id ID of the instance
	 * @param args Changes to submit
	 */
	public static function submitChanges(id:Null<Int> = null, args:Null<Dynamic> = null):Void
	{
		if (id == null)
			throw('Could not submit changes to an instance if no ID was given.');

		// If nothing given, skip
		if (args == null)
			return;

		// If invalid type, skip
		if (!Std.isOfType(args, StringMap))
			throw('Could not submit changes when changes are in the type of \'${Type.typeof(args)}\'.');

		var basic:Dynamic = FlxBasicHelper.getObject(id, FlxBasic);

		// Apply changes
		var changes:StringMap<Dynamic> = cast args;

		for (key in changes.keys())
			Reflect.setProperty(basic, key, changes.get(key));
	}

	/**
	 * Fetches the values of the given fields in the instance of the given ID
	 * @param id ID of the instance
	 * @param args Names of the fields to get
	 * @return StringMap<Dynamic> Values of each field
	 */
	public static function getChanges(id:Null<Int> = null, args:Null<Dynamic> = null):StringMap<Dynamic>
	{
		if (id == null)
			throw('Could not submit changes to an instance if no ID was given.');

		// If nothing given, skip
		if (args == null)
			return new StringMap<Dynamic>();

		// If invalid type, skip
		if (!Std.isOfType(args, Array))
			throw('Could not get changes when changes are in the type of \'${Type.typeof(args)}\'.');

		var basic:FlxBasic = FlxBasicHelper.getObject(id, FlxBasic);

		// Find changes
		var changes:Array<Dynamic> = cast args;
		var values:StringMap<Dynamic> = new StringMap<Dynamic>();

		for (key in changes)
			values.set(key, Reflect.getProperty(basic, key));

		return values;
	}
}
