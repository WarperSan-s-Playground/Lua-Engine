package engine;

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
		this.setFile(file);
		ScriptParenting.SetParent(this, parent);
	}

	// #region Properties

	/** File from which this script was created */
	public var File(default, null):String;

	/** Sets the current file to the given file */
	private function setFile(file:String):Void
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.File = fixed;
	}

	// --- PARENTING ---

	/** Parent of this script */
	public var Parent(get, null):Null<Script>;

	inline function get_Parent():Null<Script>
		return ScriptParenting.GetParent(this);

	/** Children of this script */
	public var Children(get, null):Array<Script>;

	inline function get_Children():Array<Script>
		return ScriptParenting.GetChildren(this);

	// --- DATA ---

	/** Data shared by this script */
	public var Shared(default, null):DataContainer;

	/** Data shared across all scripts */
	public static var Global(default, null):DataContainer = new DataContainer(null);

	// --- LINK ---

	/** Key used to find this script */
	public var LinkKey(default, null):Dynamic;

	// --- STATE ---

	/** Current state of this script */
	public var State(default, default):State = Running;

	// #endregion
	// #region Creation of scripts

	/**
	 * Opens another file that is related to this one. If this script closes, the other script closes too.
	 * @param file File to open
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Script created
	 */
	public function openOther(file:String, autoImport:Bool):Null<Script>
	{
		return Script.create(Type.getClass(this), file, this, autoImport);
	}

	/**
	 * Opens the given file as a script
	 * @param file File to open
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Script created
	 */
	public static function openFile(file:String, autoImport:Bool):Null<Script>
	{
		var _class:Null<Class<Dynamic>> = null;
		var extension:Null<String> = Path.extension(file);

		switch (extension)
		{
			case "lua":
				_class = LuaScript;
			default:
				throw('The extension \'$extension\' is not a supported file.');
		}

		return Script.create(_class, file, null, autoImport);
	}

	/**
	 * Creates a script from the given file
	 * @param file File to load from
	 * @param parent Parent of the script
	 * @param autoImport Automatically imports all the built-in methods
	 * @return Created script
	 */
	private static function create<T:Script>(cls:Class<T>, file:String, parent:Null<Script>, autoImport:Bool):Null<T>
	{
		// Create script
		var script:Null<T> = null;

		try
		{
			script = Type.createInstance(cls, [file, parent, autoImport]); // new LuaScript(file, parent, autoImport);
			ScriptCache.LinkScript(script.LinkKey, script);
			script.State = Open;

			try
			{
				script.State = Running;
				script.execute();
				script.State = Open;
			}
			catch (e:String)
			{
				script.State = Errored;
				LogHelper.error('Error while executing \'${script.File}\': $e');
			}

			// Callback
			var hasParent:Bool = parent != null;
			script.call("OnCreate", [hasParent], false);
		}
		catch (e:String)
		{
			LogHelper.error('Error while creating a $cls from \'$file\': $e');
			script = null;
		}
		return script;
	}

	// #endregion
	// #region Execution

	/** Executes this script */
	public abstract function execute():Void;

	/** Calls the given method in this script */
	public function call(name:String, args:Array<Dynamic>, callInChildren:Bool):Map<String, Null<Dynamic>>
	{
		// If the script has errored, skip all call
		if (this.State == Errored)
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
	public function importMethod(name:String, callback:Dynamic):Void {}

	/**
	 * Imports a whole class to this script
	 * @param builtIn Class to import from
	 */
	public function importFile(builtIn:Dynamic):Void
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
		// If already closed, skip
		if (this.State == Closed)
			return;

		this.State = Closed;

		// Close children
		for (child in ScriptParenting.GetChildren(this))
		{
			// If invalid or already closed, skip
			if (child == null || child.State == Closed)
				continue;

			child.close();
		}

		// Callback
		this.call("OnDestroy", [], false);

		// Close self
		ScriptParenting.RemoveParent(this);
		ScriptCache.UnlinkScript(this.LinkKey, this);
		this.destroy();
	}

	/** Destroys this script */
	private abstract function destroy():Void;

	// #endregion
	// #region Size Measurement

	public function getSize():Int
	{
		var size = 0;

		size += DebugHelper.getSize(this.File);
		size += DebugHelper.getSize(this.LinkKey);
		size += DebugHelper.getSize(this.Shared);
		size += DebugHelper.getSize(this.State);

		return size;
	}

	// #endregion
}

enum State
{
	/** The script is opened */
	Open;

	/** The script is currently running */
	Running;

	/** The script has errored */
	Errored;

	/** The script is closed */
	Closed;
}
