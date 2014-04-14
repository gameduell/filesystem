package filesystem;

import types.Data;
import cpp.Lib;

class File
{

	public var seekPosition (get, set) : Int;

	private var filesystem_ios_get_seek = Lib.load ("filesystem_ios", "filesystem_ios_get_seek", 1);
	public function get_seekPosition () : Int
	{
		return filesystem_ios_get_seek(nativeFileHandle);
	}

	private var filesystem_ios_set_seek = Lib.load ("filesystem_ios", "filesystem_ios_set_seek", 2);
	public function set_seekPosition (val : Int) : Int
	{
		return filesystem_ios_set_seek(nativeFileHandle, val);
	}

	private var filesystem_ios_seek_end_of_file = Lib.load ("filesystem_ios", "filesystem_ios_seek_end_of_file", 1);
	public function seekEndOfFile()
	{
		return filesystem_ios_seek_end_of_file(nativeFileHandle);
	}

	private var nativeFileHandle : Dynamic;

	/// the filesystem creates files
	public function new(nativeFileHandle : Dynamic) : Void 
	{
		this.nativeFileHandle = nativeFileHandle;
	};

	private var filesystem_ios_file_write = Lib.load ("filesystem_ios", "filesystem_ios_file_write", 2);
	public function writeFromData(data : Data)
	{
		filesystem_ios_file_write(nativeFileHandle, data.nativeData);
	}

	private var filesystem_ios_file_read = Lib.load ("filesystem_ios", "filesystem_ios_file_read", 2);
	public function readIntoData(data : Data)
	{
		filesystem_ios_file_read(nativeFileHandle, data.nativeData);
	}
	
	private var filesystem_ios_file_close = Lib.load ("filesystem_ios", "filesystem_ios_file_close", 1);
	public function close()
	{
		filesystem_ios_file_close(nativeFileHandle);
		nativeFileHandle = null;
	}
}
