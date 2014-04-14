package filesystem;
import cpp.Lib;

class Filesystem
{
	private var filesystem_ios_init = Lib.load ("filesystems_ios", "filesystem_ios_init", 0);
	private var filesystem_ios_get_url_to_static_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_static_data", 0);
	private var filesystem_ios_get_url_to_cached_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_cached_data", 0);
	private var filesystem_ios_get_url_to_temp_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_temp_data", 0);
	private function new() : Void
	{
		filesystem_ios_init();
		staticDataURL = filesystem_ios_get_url_to_static_data() + "/assets/";
		cachedDataURL = filesystem_ios_get_url_to_cached_data();
		tempDataURL = filesystem_ios_get_url_to_temp_data();
	}

	/// NATIVE ACCESS

	private var staticDataURL : String;
	public function urlToStaticData() : String
	{
		return staticDataURL;
	}

	private var cachedDataURL : String;
	public function urlToCachedData() : String
	{
		return cachedDataURL;
	}

	private var tempDataURL : String;
	public function urlToTempData() : String
	{
		return tempDataURL;
	}

	private var filesystem_ios_create_file = Lib.load ("filesystem_ios", "filesystem_ios_create_file", 1);
	public function createFile(url : String) : Bool
	{
		return filesystem_ios_create_file(url);
	}

	private var filesystem_ios_open_file_write = Lib.load ("filesystem_ios", "filesystem_ios_open_file_write", 1);
	public function getFileToWrite(url : String) : File
	{
		var nativeHandle = filesystem_ios_open_file_write(url);
		var file = new File(nativeHandle);
		return file;
	}

	private var filesystem_ios_open_file_read = Lib.load ("filesystem_ios", "filesystem_ios_open_file_read", 1);
	public function getFileToRead(url : String) : File
	{
		var nativeHandle = filesystem_ios_open_file_read(url);
		var file = new File(nativeHandle);
		return file;
	}

	private var filesystem_ios_create_folder = Lib.load ("filesystem_ios", "filesystem_ios_create_folder", 1);
	public function createFolder(url : String) : Bool
	{
		return filesystem_ios_create_folder(url);
	}

	private var filesystem_ios_delete_file = Lib.load ("filesystem_ios", "filesystem_ios_delete_file", 1);
	public function deleteFile(url : String) : Void
	{
		return filesystem_ios_delete_file(url);
	}

	private var filesystem_ios_delete_folder = Lib.load ("filesystem_ios", "filesystem_ios_delete_folder", 1);
	public function deleteFolder(url : String) : Void
	{
		return filesystem_ios_delete_folder(url);
	}

	private var filesystem_ios_url_exists = Lib.load ("filesystem_ios", "filesystem_ios_url_exists", 1);
	public function urlExists(url : String) : Bool
	{
		return filesystem_ios_url_exists(url);
	}
	
	private var filesystem_ios_is_folder = Lib.load ("filesystem_ios", "filesystem_ios_is_folder", 1);
	public function isFolder(url : String) : Bool
	{
		return filesystem_ios_is_folder(url);
	}

	private var filesystem_ios_is_file = Lib.load ("filesystem_ios", "filesystem_ios_is_file", 1);
	public function isFile(url : String) : Bool
	{
		return filesystem_ios_is_file(url);
	}

	/// SINGLETON
	static var fileSystemInstance : Filesystem;
	static public inline function instance() : Filesystem
	{
		if(fileSystemInstance == null)
		{
			fileSystemInstance = new Filesystem();
		}
		return fileSystemInstance;
	}
}

