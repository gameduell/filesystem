package filesystem;
import cpp.Lib;

import hxjni.JNI;

class Filesystem
{
	private var filesystem_android_init = Lib.load ("filesystem_android", "filesystem_android_init", 0);

	private var hxfilesystem_initialize_jni = JNI.createStaticMethod ("org/haxe/extension/HxFilesystem", "initialize", "(Lorg/haxe/hxjni/HaxeObject;)V");
	private var hxfilesystem_getCachedDataURL_jni = JNI.createStaticMethod ("org/haxe/extension/HxFilesystem", "getCachedDataURL", "()Ljava/lang/String;");
	private var hxfilesystem_getTempDataURL_jni = JNI.createStaticMethod ("org/haxe/extension/HxFilesystem", "getTempDataURL", "()Ljava/lang/String;");
	private function new() : Void
	{
		filesystem_android_init();
		hxfilesystem_initialize_jni(this);




		staticDataURL = "assets:/";
		cachedDataURL = hxfilesystem_getCachedDataURL_jni();
		tempDataURL = hxfilesystem_getTempDataURL_jni();

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

	private var filesystem_android_create_file = Lib.load ("filesystem_android", "filesystem_android_create_file", 1);
	public function createFile(url : String) : Bool
	{
		return filesystem_android_create_file(url);
	}

	private var filesystem_android_open_file_write = Lib.load ("filesystem_android", "filesystem_android_open_file_write", 1);
	public function getFileToWrite(url : String) : File
	{
		var nativeHandle = filesystem_android_open_file_write(url);
		var file = new File(nativeHandle);
		return file;
	}

	private var filesystem_android_open_file_read = Lib.load ("filesystem_android", "filesystem_android_open_file_read", 1);
	public function getFileToRead(url : String) : File
	{
		var nativeHandle = filesystem_android_open_file_read(url);
		var file = new File(nativeHandle);
		return file;
	}

	private var filesystem_android_create_folder = Lib.load ("filesystem_android", "filesystem_android_create_folder", 1);
	public function createFolder(url : String) : Bool
	{
		return filesystem_android_create_folder(url);
	}

	private var filesystem_android_delete_file = Lib.load ("filesystem_android", "filesystem_android_delete_file", 1);
	public function deleteFile(url : String) : Void
	{
		return filesystem_android_delete_file(url);
	}

	private var hxfilesystem_deleteFolderRecursively_jni = JNI.createStaticMethod ("org/haxe/extension/HxFilesystem", "deleteFolderRecursively", "(Ljava/lang/String;)V");
	public function deleteFolder(url : String) : Void
	{
		/// there is no easy way to this in c
		return hxfilesystem_deleteFolderRecursively_jni(url);
	}

	private var filesystem_android_url_exists = Lib.load ("filesystem_android", "filesystem_android_url_exists", 1);
	public function urlExists(url : String) : Bool
	{
		return filesystem_android_url_exists(url);
	}
	
	private var filesystem_android_is_folder = Lib.load ("filesystem_android", "filesystem_android_is_folder", 1);
	public function isFolder(url : String) : Bool
	{
		return filesystem_android_is_folder(url);
	}

	private var filesystem_android_is_file = Lib.load ("filesystem_android", "filesystem_android_is_file", 1);
	public function isFile(url : String) : Bool
	{
		return filesystem_android_is_file(url);
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

