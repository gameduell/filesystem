import FilesystemTest;

class MainTester
{
	public function new() {};

	static public function main() : Void 
	{
		var r = new haxe.unit.TestRunner();
		r.add(new FilesystemTest());

		r.run();

		trace(r.result.toString());
	}
}