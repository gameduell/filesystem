package filesystem;

import cpp.Lib;

import hxjni.JNI;

using StringTools;

class FileSystem
{
	
	private var filesystem_android_init = Lib.load("filesystemandroid", "filesystem_android_init", 0);

	private var j_initialize = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "initialize", "(Lorg/haxe/duell/hxjni/HaxeObject;)V");
	private var j_getCachedDataURL = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "getCachedDataURL", "()Ljava/lang/String;");
	private var j_getTempDataURL = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "getTempDataURL", "()Ljava/lang/String;");
	private function new() : Void
	{
		filesystem_android_init();
		j_initialize(this);

		staticDataURL = "assets:/";
		cachedDataURL = j_getCachedDataURL();
		tempDataURL = j_getTempDataURL();
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

	private var filesystem_android_create_file = Lib.load ("filesystemandroid", "filesystem_android_create_file", 1);
	public function createFile(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_create_file(path);
	}

	private var filesystem_android_open_file_write = Lib.load ("filesystemandroid", "filesystem_android_open_file_write", 1);
	public function getFileWriter(url : String) : FileWriter
	{
		var path = url.urlDecode();
		var nativeHandle = filesystem_android_open_file_write(path);

		if(nativeHandle == null)
			return null;

		var file = new FileWriter(nativeHandle);
		return file;
	}

	private var filesystem_android_open_file_read = Lib.load ("filesystemandroid", "filesystem_android_open_file_read", 1);
	public function getFileReader(url : String) : FileReader
	{
		var path = url.urlDecode();
		var nativeHandle = filesystem_android_open_file_read(path);

		if(nativeHandle == null)
			return null;
			
		var file = new FileReader(nativeHandle);
		return file;
	}

	private var filesystem_android_create_folder = Lib.load ("filesystemandroid", "filesystem_android_create_folder", 1);
	public function createFolder(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_create_folder(path);
	}

	private var filesystem_android_delete_file = Lib.load ("filesystemandroid", "filesystem_android_delete_file", 1);
	public function deleteFile(url : String) : Void
	{
		var path = url.urlDecode();
		return filesystem_android_delete_file(path);
	}

	private var j_deleteFolderRecursively = JNI.createStaticMethod ("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "deleteFolderRecursively", "(Ljava/lang/String;)V");
	public function deleteFolder(url : String) : Void
	{
		/// there is no easy way to this in c
		return j_deleteFolderRecursively(url);
	}

	private var filesystem_android_url_exists = Lib.load ("filesystemandroid", "filesystem_android_url_exists", 1);
	public function urlExists(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_url_exists(path);
	}
	
	private var filesystem_android_is_folder = Lib.load ("filesystemandroid", "filesystem_android_is_folder", 1);
	public function isFolder(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_is_folder(path);
	}

	private var filesystem_android_is_file = Lib.load ("filesystemandroid", "filesystem_android_is_file", 1);
	public function isFile(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_is_file(path);
	}

	/// SINGLETON
    static var fileSystemInstance : FileSystem;
    static public inline function instance() : FileSystem
    {
        return fileSystemInstance;
    }

    public static function initialize(finishedCallback : Void -> Void):Void
    {
        if(fileSystemInstance == null)
        {
            fileSystemInstance = new FileSystem();
        }

        finishedCallback();
    }
}

