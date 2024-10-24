package engine.script;

/** Message sent between the server and the client **/
typedef Message =
{
	var value:Null<Dynamic>; // Value of the message
	var isError:Bool; // Is the message an error
	var message:String; // Output of the message
};

/**
 * Creates a success message
 * @param value Value of the success
 */
function success(value:Null<Dynamic>):Message
	return {message: "Success.", value: value, isError: false};

/**
 * Creates an error message
 * @param message Message of the error
 * @param value Value of the error
 */
function error(message:String = "Message undefined", value:Null<Dynamic> = false):Message
	return {message: message, value: value, isError: true};
