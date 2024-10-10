package engine;

import haxe.io.Path;
import helpers.LogHelper;
import helpers.FileHelper;
import custom.DataContainer;

/** Class that represents an instance of a script */
abstract class Script
{
	// #region Constructor
	public function new(file:String, parent:Null<Script>)
	{
		this.setFile(file);
		ScriptParenting.SetParent(this, parent);
	}

	// #endregion
	// #region File
	private var file:String;

	/** Gets the file from which this script was created from */
	public function getFile():String
	{
		return this.file;
	}

	/** Sets the current file to the given file */
	private function setFile(file:String):Void
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		this.file = fixed;
	}

	// #endregion
	// #region Open

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
			ScriptCache.LinkScript(script.getLinkKey(), script);

			try
			{
				script.execute();
			}
			catch (e:String)
			{
				script.hasErrored = true;
				LogHelper.error('Error while executing \'${script.getFile()}\': $e');
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
	// #region Execute
	public static var LastCallResult:Map<String, Null<Dynamic>> = [];

	public var hasErrored:Bool = false;

	/** Executes this script */
	public abstract function execute():Void;

	/** Calls the given method in this script */
	public function call(name:String, args:Array<Dynamic>, callInChildren:Bool):Map<String, Null<Dynamic>>
	{
		// If the script has errored, skip all call
		if (this.hasErrored)
			return [];

		var results:Map<String, Null<Dynamic>> = [];

		// Call in self
		results.set(this.file, this.callMethod(name, args));

		if (callInChildren)
		{
			for (child in this.getChildren())
			{
				for (r in child.call(name, args, callInChildren))
					results.set(child.file, r);
			}
		}

		LastCallResult = results;

		return results;
	}

	private abstract function callMethod(name:String, args:Array<Dynamic>):Null<Dynamic>;

	// #endregion
	// #region Parent

	/** Gets the parent of this script */
	public function getParent():Null<Script>
	{
		return ScriptParenting.GetParent(this);
	}

	/** Gets the children of this script */
	public function getChildren():Array<Script>
	{
		return ScriptParenting.GetChildren(this);
	}

	// #endregion
	// #region Data
	private var shared:DataContainer;

	/** Gets the data with the given key in the shared space */
	public function getShared(key:String):Dynamic
	{
		return this.shared.get(key);
	}

	/** Sets the data with the given key in the shared space */
	public function setShared(key:String, value:Dynamic, overwrite:Bool = false, inRoot:Bool = true):Void
	{
		this.shared.set(key, value, overwrite, inRoot);
	}

	/** Removes the data with the given key in the shared space */
	public function removeShared(key:String):Void
	{
		this.shared.remove(key);
	}

	private static var global:DataContainer = new DataContainer(null);

	/** Gets the data with the given key in the global space */
	public static function getGlobal(key:String):Dynamic
	{
		return global.get(key);
	}

	/** Sets the data with the given key in the global space */
	public static function setGlobal(key:String, value:Dynamic, overwrite:Bool = false):Void
	{
		global.set(key, value, overwrite, false);
	}

	/** Removes the data with the given key in the global space */
	public static function removeGlobal(key:String):Void
	{
		global.remove(key);
	}

	// #endregion
	// #region Link

	/** Fetches the unique key that allows to find this script */
	public abstract function getLinkKey():Dynamic;

	// #endregion
	// #region Import

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
	// #region Close
	private var isClosed:Bool = false;

	/** Closes this script and the related scripts */
	public function close()
	{
		// If already closed, skip
		if (this.isClosed)
			return;

		this.isClosed = true;

		// Close children
		for (child in ScriptParenting.GetChildren(this))
		{
			// If invalid or already closed, skip
			if (child == null || child.isClosed)
				continue;

			child.close();
		}

		// Callback
		this.call("OnDestroy", [], false);

		// Close self
		ScriptParenting.RemoveParent(this);
		ScriptCache.UnlinkScript(this.getLinkKey(), this);
		this.destroy();
	}

	/** Destroys this script */
	private abstract function destroy():Void;

	// #endregion
}
