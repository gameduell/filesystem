package filesystem;

import types.Data;
import cpp.Lib;

class FileWriter
{
	private var nativeFileHandle : Dynamic;

	public var seekPosition (get, set) : Int;

	private var filesystem_android_get_seek = Lib.load ("filesystem_android", "filesystem_android_get_seek", 1);
	public function get_seekPosition () : Int
	{
		return filesystem_android_get_seek(nativeFileHandle);
	}

	private var filesystem_android_set_seek = Lib.load ("filesystem_android", "filesystem_android_set_seek", 2);
	public function set_seekPosition (val : Int) : Int
	{
		return filesystem_android_set_seek(nativeFileHandle, val);
	}

	private var filesystem_android_seek_end_of_file = Lib.load ("filesystem_android", "filesystem_android_seek_end_of_file", 1);
	public function seekEndOfFile()
	{
		return filesystem_android_seek_end_of_file(nativeFileHandle);
	}

	/// the filesystem creates files
	public function new(nativeFileHandle : Dynamic) : Void 
	{
		this.nativeFileHandle = nativeFileHandle;
	};

	private var filesystem_android_file_write = Lib.load ("filesystem_android", "filesystem_android_file_write", 2);
	public function writeFromData(data : Data)
	{
		filesystem_android_file_write(nativeFileHandle, data.nativeData);
	}
	
	private var filesystem_android_file_close = Lib.load ("filesystem_android", "filesystem_android_file_close", 1);
	public function close()
	{
		filesystem_android_file_close(nativeFileHandle);
		nativeFileHandle = null;
	}
}
