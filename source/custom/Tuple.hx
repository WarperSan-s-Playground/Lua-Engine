package custom;

/**
 * Class that holds two values
 */
class Tuple<T1, T2>
{
	public var first:T1;
	public var second:T2;

	public function new(first:T1, second:T2)
	{
		this.first = first;
		this.second = second;
	}
}
