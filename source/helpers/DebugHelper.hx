package helpers;

import haxe.ds.StringMap;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxStringUtil;
import cpp.vm.Gc;
import flixel.FlxG;
import flixel.system.debug.stats.Stats;
import haxe.Constraints.IMap;
import interfaces.IMeasurable;
import engine.ScriptParenting;
import engine.Script;

/** Handles debug methods */
class DebugHelper
{
	public static function printState():String
	{
		var result:String = "";

		result += "===== DEBUG REPORT =====\n";
		result += "\n" + memoryUsage();
		result += "\n" + objectHierarchy();
		result += "\n" + scripts();
		result += "\n" + cache();
		result += "\n=========================";

		return result;
	}

	public static function getSize(value:Dynamic):Int
	{
		// Measure custom
		if (Std.isOfType(value, IMeasurable))
			return cast(value, IMeasurable).getSize();

		// Measure bool
		if (Std.isOfType(value, Bool))
			return 1;

		// Measure int
		if (Std.isOfType(value, Int))
			return 4;

		// Measure float (here, it's double)
		if (Std.isOfType(value, Float))
			return 8;

		// Measure string
		if (Std.isOfType(value, String))
		{
			var length = cast(value, String).length;
			return 4 + length * 2; // 4 bytes for length + 2 bytes per char for UTF-16
		}

		// Measure map
		if (Std.isOfType(value, IMap))
		{
			var map:IMap<Dynamic, Dynamic> = cast value;
			var size = 4; // Reference

			for (i in map.keys())
			{
				size += getSize(i);
				size += getSize(map.get(i));
			}

			return size;
		}

		// Measure FlxGraphic
		if (Std.isOfType(value, FlxGraphic))
		{
			var bitmap:BitmapData = cast(value, FlxGraphic).bitmap;
			return bitmap.width * bitmap.height * 4; // Assuming RGBA format (4 bytes per pixel)
		}

		// Measure Sound
		if (Std.isOfType(value, Sound))
		{
			var sound:Sound = cast value;
			return Std.int(sound.length / 1000) * sound.sampleRate * 2; // 2 bytes per sample (16-bit)
		}

		LogHelper.warn('The type \'${Type.getClassName(Type.getClass(value))}\' is not supported for the size measurement.');
		return 0;
	}

	private static function memoryUsage():String
	{
		var stats:Stats = new Stats();
		var result:String = "[ MEMORY USAGE ]\n";

		var memUsed:Float = openfl.system.System.totalMemory;
		var memAlloc:Float = Gc.memInfo64(Gc.MEM_INFO_RESERVED);

		result += '- Total: ${FlxStringUtil.formatBytes(memUsed + memAlloc)}\n';
		result += '- Used: ${FlxStringUtil.formatBytes(memUsed)}\n';
		result += '- Allocated: ${FlxStringUtil.formatBytes(memAlloc)}\n';

		return result;
	}

	private static function objectHierarchy():String
	{
		var result:String = "[ OBJECT HIERARCHY ]\n";

		result += printMembers(FlxG.state, 0);

		return result;
	}

	private static function printMembers(basic:FlxBasic, level:Int):String
	{
		var result:String = "";
		for (i in 0...level)
			result += "   ";

		var liveStatus:String = basic.alive ? "ACTIVE" : "INACTIVE";

		result += '- ${Type.getClassName(Type.getClass(basic))} (ID: ${basic.ID}) (${liveStatus})\n';

		if (Std.isOfType(basic, FlxGroup))
		{
			var group:FlxGroup = cast basic;

			for (i in group.members)
			{
				// If empty entry, skip
				if (i == null)
					continue;

				result += printMembers(i, level + 1);
			}
		}

		return result;
	}

	private static function scripts():String
	{
		var roots:Array<Script> = ScriptParenting.GetAll(false);
		var result:String = "[ SCRIPTS ]\n";

		var i:Int = 0;
		while (i < roots.length)
		{
			result += printScript(roots[i], i == roots.length - 1, 0);
			i++;
		}

		return result;
	}

	private static function printScript(script:Script, isLast:Bool, level:Int):String
	{
		var offset:String = "";
		var file:String = "";
		var memory:String = "";
		var status:String = "";
		var children:String = "";

		// Offset
		for (i in 0...level)
			offset += "\t";

		// File
		file = script.File;

		// Memory
		memory = Std.string(script.getSize()) + "B";

		// Status
		switch (script.State)
		{
			case Open:
				status = "O";
			case Running:
				status = "R";
			case Errored:
				status = "E";
			case Closed:
				status = "C";
			default:
				status = "?";
		}

		// Children
		var _children = script.Children;
		var i:Int = 0;
		while (i < _children.length)
		{
			if (isLast)
				children += " ";
			else
				children += "│";

			children += printScript(_children[i], i == _children.length - 1, level + 1);

			i++;
		}

		return '$offset- $file (Mem: $memory | Status: $status)\n$children';
	}

	private static function cache():String
	{
		var result:String = "[ CACHE ]\n";
		var total:Int = 0;

		var entries:Array<Array<Dynamic>> = [];

		for (key in ResourceHelper.loaded.keys())
		{
			var size:Int = getSize(ResourceHelper.loaded.get(key));
			entries.push([key, size, '- ${key} (${FlxStringUtil.formatBytes(size)})\n']);
			total += size;
		}

		result += "By Size:\n";
		entries.sort(function(a, b):Int {
			return Std.int(b[1] - a[1]);
		});

		for (i in entries)
			result += i[2];

		result += "\nBy Name:\n";
		entries.sort(function(a, b):Int {
			var sA:String = cast(a[0], String).split('/').pop();
			var sB:String = cast(b[0], String).split('/').pop();
			return sB < sA ? 1 : (sB > sA ? -1 : 0);
		});

		for (i in entries)
			result += i[2];

		result += 'Total: ${FlxStringUtil.formatBytes(total)}\n';

		return result;
	}
}
