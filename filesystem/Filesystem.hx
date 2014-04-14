package filesystem;

extern class Filesystem
{
	private function new() : Void;

	public static function instance() : Filesystem;

	public function urlToStaticData() : String;
	public function urlToCachedData() : String;
	public function urlToTempData() : String;

	public function getFileToWrite(url : String) : File;
	public function getFileToRead(url : String) : File;
	public function createFile(url : String) : Bool;
	public function createFolder(url : String) : Bool;

	public function urlExists(url : String) : Bool;
	public function isFolder(url : String) : Bool;
	public function isFile(url : String) : Bool;

	public function deleteFile(url : String) : File;
	public function deleteFolder(url : String) : File;
}


