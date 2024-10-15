package builtin;

import helpers.FileHelper;

@:rtti
class CacheBuiltIn
{
	public static function cacheResource(file:Null<String> = null):Void
	{
		if (file == null)
			throw('Cannot cache a resource without specifying it\'s path.');

		FileHelper.Load(file);
	}

	public static function releaseResource(file:Null<String> = null):Void
	{
		if (file == null)
			throw('Cannot release a resource without specifying it\'s path.');

		FileHelper.Release(file);
	}
}
