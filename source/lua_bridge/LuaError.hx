package lua_bridge;

/**
 * Result for a built-in lua method
 */
class LuaError
{
	/**
	 * Creates an lua method object
	 * @param message Message of the method
	 * @param value Value of the method
	 * @param isError Is the object an error
	 * @return Dynamic Lua method object
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
	 * @return Dynamic Error
	 */
	public static function error(message:String = "Message undefined", value:Dynamic = false):Dynamic
	{
		return create(message, value, true);
	}

	/**
	 * Creates a success
	 * @param value Value of the success
	 * @return Dynamic Success
	 */
	public static function success(value:Dynamic = true):Dynamic
	{
		return create("Succeed.", value, false);
	}
}
