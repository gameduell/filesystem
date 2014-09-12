import FilesystemTest;
import filesystem.FileSystem;
class MainTester
{
	public function new() {};

	static public function main() : Void 
	{
		FileSystem.initialize(function() : Void{
			var r = new haxe.unit.TestRunner();
			r.add(new FileSystemTest());
			r.run();
		});
	}
}