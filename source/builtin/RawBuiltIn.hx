package builtin;

import helpers.FlxBasicHelper;
import flixel.FlxBasic;
import helpers.ClassHelper;

@:rtti
class RawBuiltIn
{
	/**
	 * Fetches the raw value at the given path
	 * @param path Path to the value request.
	 */
	public static function getRaw(path:Null<String> = null):Dynamic
	{
		// If not defined, skip
		if (path == null)
			throw('Cannot get a value from an undefined path.');

		var result:Dynamic = ClassHelper.getClassFromPath(path);
		var obj:Null<Dynamic> = ClassHelper.getClassField(result.obj, result.field);

		// If the field has no value, skip
		if (obj == null)
			return null;

		if (Reflect.isObject(obj))
			return Std.string(obj);

		return obj;
	}

	/**
	 * Sets the raw value at the given path to the given value
	 * @param path Path to the value request.
	 * @param value Value to assign
	 */
	public static function setRaw(path:Null<String> = null, value:Null<Dynamic> = null):Void
	{
		// If not defined, skip
		if (path == null)
			throw('Cannot get a value from an undefined path.');

		var result:Dynamic = ClassHelper.getClassFromPath(path);
		var segments:Array<String> = result.field.split('.');
		var lastField:Null<String> = segments.pop();

		var field:Dynamic = null;

		// Search in object
		if (segments.length > 1)
			field = ClassHelper.getClassField(result.obj, segments.join('.'));
		// Take from object
		else
			field = result.obj;

		Reflect.setProperty(field, lastField, value);
	}

	/**
	 * Calls the method at the given path
	 * @param path Path to the value request.
	 * @param args Arguments of the call
	 * @return Result of the call
	 */
	public static function callRaw(path:Null<String> = null, args:Dynamic = null):Null<Dynamic>
	{
		// If not defined, skip
		if (path == null)
			throw('Cannot get a value from an undefined path.');

		var result:Dynamic = ClassHelper.getClassFromPath(path);
		var method:Dynamic = ClassHelper.getClassField(result.obj, result.field);

		if (method == null)
			throw('No method found with the path \'$path\'.');

		if (args == null)
			args = [];

		return Reflect.callMethod(result.obj, method, args);
	}

	/**
	 * Creates an instance of the given type from the given arguments
	 * @param name Full name of the class
	 * @param args Arguments for the constructor
	 * @return Null<Int> Unique identifier used to cache this instance
	 */
	public static function createRaw(name:Null<String> = null, args:Dynamic = null):Null<Int>
	{
		if (name == null)
			throw('Could not create an instance if no class was given.');

		// Find class
		var classType:Null<Class<Dynamic>> = ClassHelper.getClassFromName(name);

		if (classType == null)
			throw('Could not find the class for the type \'$name\'.');

		// Create instance
		var instance:Null<Dynamic> = Type.createInstance(classType, args);

		if (instance == null)
			throw('Could not create an instance of the type \'$name\'.');

		// Cache instance
		if (Std.isOfType(instance, FlxBasic))
			return FlxBasicHelper.add(instance);
		return null;
	}

	/**
	 * Destroys the instance with the given ID
	 * @param name Full name of the class
	 * @param id ID of the instance to remove
	 */
	public static function destroyRaw(name:Null<String> = null, id:Null<Int> = null):Void
	{
		if (id == null)
			throw('Could not destroy an instance if no ID was given.');

		if (name == null)
			throw('Could not destroy an instance if no class was given.');

		// Find class
		var classType:Null<Class<Dynamic>> = ClassHelper.getClassFromName(name);

		// Manage basics
		while (true)
		{
			classType = Type.getSuperClass(classType);

			// If reached end, exit
			if (classType == null)
				break;

			// If class is FlxBasic, destroy
			if (classType == FlxBasic)
			{
				FlxBasicHelper.remove(id);
				return;
			}
		}

		throw('Could not find the class for the type \'$name\'.');
	}
}
