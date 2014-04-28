package filesystem;

import types.Data;

extern class FileWrite
{
	/// the filesystem creates the filewriter
	private function new() : Void;

	public var seekPosition (get, set) : Int;

	public function seekEndOfFile();

	public function writeFromData(data : Data);

	public function close();
}