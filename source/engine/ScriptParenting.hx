package engine;

import engine.script.Script;
import helpers.FileHelper;
import custom.PointerMap;

/** Class that manages the parenting of the scripts */
class ScriptParenting
{
	private static var roots:Array<Script> = [];
	private static var parentMap:PointerMap<Script, Script> = new PointerMap<Script, Script>();

	// #region Parent

	/** Fetches the parent of the given child */
	public static function GetParent(child:Script):Null<Script>
	{
		// If child is root, return
		if (roots.contains(child))
			return null;

		return parentMap.get(child);
	}

	/** Sets the parent of the given child to the given parent */
	public static function SetParent(child:Script, parent:Script):Void
	{
		// Remove the current parent of the script
		RemoveParent(child);

		// If root, add to roots
		if (parent == null)
			roots.push(child);
		else
			parentMap.set(child, parent);
	}

	/** Removes the parent of the given script */
	public static function RemoveParent(script:Script):Void
	{
		parentMap.remove(script);
		roots.remove(script);
	}

	// #endregion
	// #region Child

	/** Fetches all the children of the given parent */
	public static function GetChildren(parent:Script):Array<Script>
	{
		var children:Array<Script> = [];

		for (key in parentMap.keys())
		{
			if (key == null)
				continue;

			if (parentMap.get(key) != parent)
				continue;

			children.push(key);
		}

		return children;
	}

	/** Fetches all the scripts */
	public static function GetAll(getChildren:Bool):Array<Script>
	{
		var results:Array<Script> = [];
		var remaining:Array<Script> = [];

		for (i in roots)
			remaining.push(i);

		while (remaining.length > 0)
		{
			var current:Script = remaining.pop();
			results.push(current);

			if (getChildren)
			{
				for (child in current.Children)
					remaining.push(child);
			}
		}

		return results;
	}

	// #endregion

	/** Finds the first script that is the given file */
	public static function Find(file:String):Null<Script>
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		// Search in roots
		for (root in roots)
		{
			if (root.File == fixed)
				return root;
		}

		// Search in children
		for (child in parentMap.keys())
		{
			if (child.File == fixed)
				return child;
		}

		return null;
	}
}
