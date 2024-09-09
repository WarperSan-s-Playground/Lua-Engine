package lua_bridge;

import custom.PointerMap;
import helpers.FileHelper;

/**
 * Class that manages the parenting of the scripts
 */
class LuaParenting
{
	private static var roots:Array<LuaScript> = [];
	private static var parentMap:PointerMap<LuaScript, LuaScript> = new PointerMap<LuaScript, LuaScript>();

	/** Sets the parent of the given child to the given parent */
	public static function SetParent(child:LuaScript, parent:LuaScript):Void
	{
		RemoveParent(child);

		// If root, add to roots
		if (parent == null)
			roots.push(child);
		else
			parentMap.set(child, parent);
	}

	/** Fetches the parent of the given child */
	public static function GetParent(child:LuaScript):Null<LuaScript>
	{
		// If child is root, return
		if (roots.contains(child))
			return null;

		var parent:Null<LuaScript> = parentMap.get(child);

		// If parent found, return
		if (parent != null)
			return parent;

		throw('The script \'${child.file}\' is not a root nor a child of any script.');
	}

	/** Removes the parent of the given script */
	public static function RemoveParent(script:LuaScript):Void
	{
		parentMap.remove(script);
		roots.remove(script);
	}

	/** Fetches all the children of the given parent */
	public static function GetChildren(parent:LuaScript):Array<LuaScript>
	{
		var children:Array<LuaScript> = [];

		for (key in parentMap.keys())
		{
			if (parentMap.get(key) == parent)
				children.push(key);
		}

		return children;
	}

	/** Finds the first script that is the given file */
	public static function Find(file:String):Null<LuaScript>
	{
		var fixed:Null<String> = FileHelper.GetPath(file);

		if (fixed == null)
			throw('Could not find the file at \'$file\'.');

		// Search in roots
		for (root in roots)
		{
			if (root.file == fixed)
				return root;
		}

		// Search in children
		for (child in parentMap.keys())
		{
			if (child.file == fixed)
				return child;
		}

		return null;
	}

	/** Fetches all the scripts */
	public static function GetAll(getChildren:Bool):Array<LuaScript>
	{
		var results:Array<LuaScript> = [];
		var remaining:Array<LuaScript> = [];

		for (i in roots)
			remaining.push(i);

		while (remaining.length > 0)
		{
			var current:LuaScript = remaining.pop();
			results.push(current);

			for (child in LuaParenting.GetChildren(current))
				remaining.push(child);
		}

		return results;
	}
}
