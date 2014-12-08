package filesystem;

extern class FileSystem
{
	private function new() : Void;
	public static function initialize(finishedCallback : Void->Void ):Void;
	public static function instance() : FileSystem;

	public function urlToStaticData() : String;
	public function urlToCachedData() : String;
	public function urlToTempData() : String;

	public function getFileWriter(url : String) : FileWriter;
	public function getFileReader(url : String) : FileReader;
	public function createFile(url : String) : Bool;
	public function createFolder(url : String) : Bool;

	public function urlExists(url : String) : Bool;
	public function isFolder(url : String) : Bool;
	public function isFile(url : String) : Bool;

	public function getFileSize() : Int;

	public function deleteFile(url : String) : Void;
	public function deleteFolder(url : String) : Void;
}


