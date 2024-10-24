package engine.script;

import engine.script.BuiltIns.BUILT_IN;
import engine.script.Status;
import haxe.io.Path;
import helpers.LogHelper;
import helpers.FileHelper;
import custom.DataContainer;

/** Class that represents an instance of a script */
abstract class Script
{
	public function new(file:String, parent:Null<Script>)
	{
		this.File = file;
		this.Parent = parent;
		this.Shared = new DataContainer(this);
		this.Events = new Events(this);
	}

	// #region Properties

	/** File from which this script was created */
	public var File(default, set):String;

	private function set_File(value:String):String
	{
		// Set file
		var fixed:Null<String> = FileHelper.GetPath(value);

		if (fixed == null)
			throw('Could not find the file at \'$value\'.');

		this.File = fixed;
		return fixed;
	}

	// --- PARENTING ---

	/** Parent of this script */
	public var Parent(get, set):Null<Script>;

	private inline function get_Parent():Null<Script>
		return ScriptParenting.GetParent(this);

	private function set_Parent(value:Null<Script>):Null<Script>
	{
		ScriptParenting.SetParent(this, value);
		return value;
	}

	/** Children of this script */
	public var Children(get, null):Array<Script> = [];

	inline function get_Children():Array<Script>
		return ScriptParenting.GetChildren(this);

	// --- DATA ---

	/** Data shared by this script */
	public final Shared:DataContainer;

	/** Data shared across all scripts */
	public static var Global(default, null):DataContainer = new DataContainer(null);

	// --- LINK ---

	/** Key used to find this script */
	public var LinkKey(default, set):Dynamic;

	private function set_LinkKey(value:Dynamic):Dynamic
	{
		// If unset the key, unlink
		if (value == null)
		{
			ScriptCache.UnlinkScript(this.LinkKey, this);
			this.LinkKey = null;
			return null;
		}

		// If script already linked, unlink
		if (this.LinkKey != null)
		{
			LogHelper.warn('Relinking the script \'${this.File}\'.');
			ScriptCache.UnlinkScript(this.LinkKey, this);
		}

		ScriptCache.LinkScript(value, this);
		this.LinkKey = value;

		return value;
	}

	// --- STATE ---

	/** Current state of this script */
	public var State(default, set):Status = OPEN;

	private function set_State(value:Status):Status
	{
		// If closed, skip
		if (this.State == CLOSED)
			return CLOSED;

		// If closing, override all
		if (value == CLOSED)
		{
			this.State = CLOSED;
			return CLOSED;
		}

		this.State = value;
		return value;
	}

	// --- EVENTS ---
	public final Events:Events;

	// #endregion
	// #region Creation of scripts

	/**
	 * Opens the given file as a script
	 * @param file File to open
	 * @param parent Parent of the new script
	 * @return Script created
	 */
	public static function openFile(file:String, parent:Null<Script>):Null<Script>
	{
		// Create script
		var script:Null<Script> = null;
		var cls:Class<Dynamic> = getScriptClass(file);

		try
		{
			script = Type.createInstance(cls, [file, parent]);
		}
		catch (e:String)
		{
			LogHelper.error('Error while creating a \'$cls\' from \'$file\': $e');
			script = null;
		}

		// If errored, skip
		if (script == null)
			return null;

		// Import built-ins
		for (builtIn in BUILT_IN)
		{
			// Add each field
			for (field in Type.getClassFields(builtIn))
			{
				var callback:Dynamic = Reflect.field(builtIn, field);

				// If callback invalid, skip
				if (callback == null)
					continue;

				// If not a function, skip
				if (!Reflect.isFunction(callback))
					continue;

				script.set(field, callback);
			}
		}

		try
		{
			script.State = RUNNING;
			script.execute();

			// Callback
			script.Events.OnCreate(parent != null);

			script.State = OPEN;
		}
		catch (e:String)
		{
			script.State = ERRORED;
			LogHelper.error('Error while executing \'${script.File}\': $e');
		}

		return script;
	}

	/** Fetches the script type for the given file */
	private static function getScriptClass(file:String):Class<Dynamic>
	{
		var cls:Null<Class<Dynamic>> = null;
		var extension:Null<String> = Path.extension(file).toLowerCase();

		switch (extension)
		{
			case "lua":
				cls = engine.lua.LuaScript;
			case "hx":
				cls = engine.hscript.HScript;
			default:
				throw('The extension \'$extension\' is not a supported file.');
		}

		return cls;
	}

	// #endregion
	// #region Closing

	/** Closes this script and the related scripts */
	public function close()
	{
		// If already CLOSED, skip
		if (this.State == CLOSED)
			return;

		this.State = CLOSED;

		// Close children
		for (child in this.Children)
			child.close();

		// Callback
		this.Events.OnDestroy();
		this.destroy();

		// Remove from systems
		this.Parent = null;
		this.LinkKey = null;
	}

	// #endregion
	// #region Abstract

	/** Executes this script */
	public abstract function execute():Void;

	/**
	 * Calls the method of the given name with the given arguments
	 * @param name Name of the method to call
	 * @param args Arguments to use in the call
	 * @return Result of the call
	 */
	public abstract function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>;

	/**
	 * Sets the global of the given name to the given value
	 * @param name Name of the global value
	 * @param value Value of the global
	 */
	private abstract function set(name:String, value:Dynamic):Void;

	/** Destroys this script */
	private abstract function destroy():Void;

	// #endregion
}
