package engine.script;

import engine.script.BuiltIns.BUILT_IN;
import engine.script.Status;
import helpers.DebugHelper;
import interfaces.IMeasurable;
import haxe.io.Path;
import helpers.LogHelper;
import helpers.FileHelper;
import custom.DataContainer;

/** Class that represents an instance of a script */
abstract class Script implements IMeasurable
{
	public function new(file:String, parent:Null<Script>)
	{
		// Set file
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.File = fixed;

		// Set parent
		this.Parent = parent;

		// Set data
		this.Shared = new DataContainer(this);

		// Set events
		this.Events = new Events(this);
	}

	// #region Properties

	/** File from which this script was created */
	public final File:String;

	// --- PARENTING ---

	/** Parent of this script */
	public var Parent(get, set):Null<Script>;

	inline function get_Parent():Null<Script>
		return ScriptParenting.GetParent(this);

	function set_Parent(value:Null<Script>):Null<Script>
	{
		if (value == null && this.Parent != null)
			ScriptParenting.RemoveParent(this);
		else
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
	public var LinkKey(default, null):Dynamic;

	// --- STATE ---

	/** Current state of this script */
	public var State(default, default):Status = RUNNING;

	// #endregion
	// #region Creation of scripts

	/**
	 * Opens the given file as a script
	 * @param file File to open
	 * @param parent Parent of the new script
	 * @return Script created
	 */
	public inline static function openFile(file:String, parent:Null<Script>):Null<Script>
	{
		// Create script
		var script:Null<Dynamic> = null;
		var cls:Class<Dynamic> = getScriptClass(file);

		try
		{
			script = Type.createInstance(cls, [file, parent]);
			ScriptCache.LinkScript(script.LinkKey, script);

			// Import built-ins
			for (i in BUILT_IN)
				script.importFile(i);

			try
			{
				script.State = RUNNING;
				script.execute();
				script.State = OPEN;
			}
			catch (e:String)
			{
				script.State = ERRORED;
				LogHelper.error('Error while executing \'${script.File}\': $e');
			}

			// Callback
			script.Events.OnCreate(parent != null);
		}
		catch (e:String)
		{
			LogHelper.error('Error while creating a \'$cls\' from \'$file\': $e');
			script = null;
		}

		return script;
	}

	/** Fetches the script type for the given file */
	private static function getScriptClass(file:String):Class<Dynamic>
	{
		var cls:Null<Class<Dynamic>> = null;
		var extension:Null<String> = Path.extension(file);

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
	// #region Execution

	/** Executes this script */
	public abstract function execute():Void;

	/** Calls the given method in this script */
	public function call(name:String, args:Array<Dynamic>, callInChildren:Bool):Map<String, Null<Dynamic>>
	{
		// If the script has ERRORED, skip all call
		if (this.State == ERRORED)
			return [];

		var results:Map<String, Null<Dynamic>> = [];

		// Call in self
		results.set(this.File, this.callMethod(name, args));

		if (callInChildren)
		{
			for (child in this.Children)
			{
				for (r in child.call(name, args, callInChildren))
					results.set(child.File, r);
			}
		}

		return results;
	}

	private abstract function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>;

	// #endregion
	// #region Importing

	/**
	 * Imports a single method to this script
	 * @param name Name of the method
	 * @param callback Action to call
	 */
	private function importMethod(name:String, callback:Dynamic):Void {}

	/**
	 * Imports a whole class to this script
	 * @param builtIn Class to import from
	 */
	private function importFile(builtIn:Dynamic):Void
	{
		var fields:Array<String> = Type.getClassFields(builtIn);

		// Add each field
		for (field in fields)
		{
			var callback:Dynamic = Reflect.field(builtIn, field);

			// If not a function, skip
			if (!Reflect.isFunction(callback))
				continue;

			this.importMethod(field, callback);
		}
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
		for (child in ScriptParenting.GetChildren(this))
		{
			// If invalid, skip
			if (child == null)
				continue;

			child.close();
		}

		// Callback
		this.Events.OnDestroy();

		// Close self
		this.Parent = null;
		ScriptCache.UnlinkScript(this.LinkKey, this);
		this.destroy();
	}

	/** Destroys this script */
	private abstract function destroy():Void;

	// #endregion
	// #region Events
	public final Events:Events;

	// #endregion
	// #region Size Measurement

	public function getSize():Int
	{
		var size = 0;

		size += DebugHelper.getSize(this.File);
		size += DebugHelper.getSize(this.Shared);
		size += DebugHelper.getSize(this.State);

		return size;
	}

	// #endregion
}
