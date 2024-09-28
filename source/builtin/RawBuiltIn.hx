package builtin;

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
        var result:Dynamic = ClassHelper.getClassFromPath(path);
		return ClassHelper.getClassField(result.obj, result.path);
	}

	/**
	 * Sets the raw value at the given path to the given value
	 * @param path Path to the value request.
	 * @param value Value to assign
	 */
	public static function setRaw(path:Null<String> = null, value:Null<Dynamic> = null):Void
	{
        var result:Dynamic = ClassHelper.getClassFromPath(path);
		var segments:Array<String> = result.path.split('.');
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
	 * @param ...args Arguments of the call
	 * @return Result of the call
	 */
	public static function callRaw(path:Null<String> = null, ...args):Null<Dynamic>
	{
		var result:Dynamic = ClassHelper.getClassFromPath(path);
		var method:Dynamic = ClassHelper.getClassField(result.obj, result.path);

		if (method == null)
			throw('No method found with the path \'$path\'.');

		if (args == null)
			args = [];

		return Reflect.callMethod(result.obj, method, args);
	}
}