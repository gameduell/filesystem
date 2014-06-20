
import lime.Lime;

import FilesystemTest;

import platform.AppMain;
import platform.Platform;

class MainTester extends AppMain
{
	public function new() {};

	override public function start () : Void 
	{
		var r = new haxe.unit.TestRunner();
		r.add(new FilesystemTest());

		r.run();

		trace(r.result.toString());
	}
}