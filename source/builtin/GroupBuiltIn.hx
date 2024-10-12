package builtin;

import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import helpers.FlxBasicHelper;
import flixel.group.FlxGroup;

@:rtti
class GroupBuiltIn
{
	/**
	 * Creates a new `FlxGroup`
	 * @param maxSize Maximum amount of members allowed
	 * @return Unique ID of the added element
	 */
	public static function createGroup(maxSize:Int = 0):Int
	{
		var newGroup:FlxGroup = new FlxGroup(maxSize);

		return FlxBasicHelper.add(newGroup);
	}

	/**
	 * Removes the group with the given ID
	 * @param id ID of the group to remove
	 * @param forceDestroy Force the game to destroy the group
	 */
	public static function removeGroup(id:Int = -1, forceDestroy:Bool = false):Void
	{
		var group:FlxGroup = cast FlxBasicHelper.getObject(id, FlxGroup);

		if (forceDestroy || group.container == null)
			group.destroy();
		else
			group.kill();
	}

	/**
	 * Adds the given element to the given group
	 * @param groupID ID of the group to add to
	 * @param elementID ID of the element to add
	 */
	public static function addToGroup(groupID:Int = -1, elementID:Int = -1):Void
	{
		var basic:Dynamic = FlxBasicHelper.getObject(groupID, FlxBasic);
		var element:FlxBasic = cast FlxBasicHelper.getObject(elementID, FlxBasic);

		// If not a group, skip
		if (!Std.isOfType(basic, FlxTypedGroup) && !Std.isOfType(basic, FlxSpriteGroup))
			throw('Could not find a group with the ID \'$groupID\'.');

		var group:Dynamic = basic;

		// Special case for FlxSpriteGroup
		if (Std.isOfType(basic, FlxSpriteGroup))
			group = basic.group;

		// If already inside, skip
		if (group.members.indexOf(element) != -1)
			throw('The element with the ID \'$elementID\' is already part of the group with the ID \'$groupID\'.');

		group.add(element);
	}

	/**
	 * Removes the given element from the given group
	 * @param groupID ID of the group to remove from
	 * @param elementID ID of the element to remove
	 */
	public static function removeFromGroup(groupID:Int = -1, elementID:Int = -1):Void
	{
		var group:FlxTypedGroup<FlxBasic> = cast FlxBasicHelper.getObject(groupID, FlxTypedGroup);
		var element:FlxBasic = cast FlxBasicHelper.getObject(elementID, FlxBasic);

		group.remove(element, true);
	}
}
