package lua_bridge;

/**
 * Result for a built-in lua method
 */
class LuaMessage
{
	/**
	 * Creates an lua method object
	 * @param message Message of the method
	 * @param value Value of the method
	 * @param isError Is the object an error
	 * @return Lua method object
	 */
	private static function create(message:String, value:Null<Dynamic>, isError:Bool):Dynamic
	{
		return {
			message: message,
			value: value,
			isError: isError
		};
	}

	/**
	 * Creates an error
	 * @param message Message of the error
	 * @param value Value of the error
	 */
	public static function error(message:String = "Message undefined", value:Dynamic = false):Dynamic
	{
		return create(message, value, true);
	}

	/**
	 * Creates a success
	 * @param value Value of the success
	 */
	public static function success(value:Dynamic = true):Dynamic
	{
		return create("Success.", value, false);
	}
}
