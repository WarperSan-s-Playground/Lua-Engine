package builtin;

import helpers.ResourceHelper;

@:rtti
class CacheBuiltIn
{
	/**
	 * Caches the given resource
	 * @param file Path to the resource
	 * @return Succeed to cache the resource asked
	 */
	 public static function cacheResource(file:Null<String> = null):Bool
	{
		if (file == null)
			throw('Cannot cache a resource without specifying it\'s path.');

		var resource:Null<Dynamic> = ResourceHelper.Load(file);
		return resource != null;
	}

	/**
	 * Releases the given resource
	 * @param file Path to the resource
	 * @return Succeed to release the resource specified
	 */
	public static function releaseResource(file:Null<String> = null):Bool
	{
		if (file == null)
			throw('Cannot release a resource without specifying it\'s path.');

		return ResourceHelper.Release(file);
	}
}
