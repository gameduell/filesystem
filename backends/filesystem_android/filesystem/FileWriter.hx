package filesystem;

import types.Data;
import cpp.Lib;

class FileWriter
{
	private var nativeFileHandle : Dynamic;

	public var seekPosition (get, set) : Int;

	private var filesystem_android_get_seek = Lib.load ("filesystemandroid", "filesystem_android_get_seek", 1);
	public function get_seekPosition () : Int
	{
		return filesystem_android_get_seek(nativeFileHandle);
	}

	private var filesystem_android_set_seek = Lib.load ("filesystemandroid", "filesystem_android_set_seek", 2);
	public function set_seekPosition (val : Int) : Int
	{
		return filesystem_android_set_seek(nativeFileHandle, val);
	}

	/// the filesystem creates files
	public function new(nativeFileHandle : Dynamic) : Void 
	{
		this.nativeFileHandle = nativeFileHandle;
	};

	private var filesystem_android_file_write = Lib.load ("filesystemandroid", "filesystem_android_file_write", 2);
	public function writeFromData(data : Data)
	{
		filesystem_android_file_write(nativeFileHandle, data.nativeData);
	}
	
	private var filesystem_android_file_close = Lib.load ("filesystemandroid", "filesystem_android_file_close", 1);
	public function close()
	{
		filesystem_android_file_close(nativeFileHandle);
		nativeFileHandle = null;
	}
}
