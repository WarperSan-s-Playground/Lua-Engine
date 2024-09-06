package custom;

/**
 * Class that mimics the behaviour of a HashMap while working on pointers
 */
class PointerMap<T1, T2>
{
	private var data:Array<Array<Dynamic>> = [];

	public function new() {}

	/** Sets the given value to the given key */
	public function set(key:T1, value:T2):Void
	{
        var index:Int = this.indexOf(key);
		if (index != -1)
		{
			this.data[index][1] = value;
            return;
		}

		this.data.push([key, value]);
	}

	/** Removes the given key */
	public function remove(key:T1):Void
	{
        var index:Int = this.indexOf(key);
        this.data.splice(index, 1);
	}

	/** Checks if the key exists */
	public function exists(key:T1):Bool
	{
		return this.indexOf(key) != -1;
	}

	/** Fetches the value of the key */
	public function get(key:T1):Null<T2>
	{
		var index:Int = this.indexOf(key);

        if (index == -1)
            return null;

        return this.data[index][1];
	}

	/** Fetches the index of the given key */
	public function indexOf(key:T1):Int
	{
		var i:Int = 0;
		for (item in this.data)
		{
			if (item[0] == key)
				return i;

			i++;
		}

		return -1;
	}
}
