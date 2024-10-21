package engine.script;

/** Message sent between the server and the client **/
typedef Message = {
    var value:Null<Dynamic>; // Value of the message
    var isError:Bool; // Is the message an error
    var message:String; // Output of the message
};