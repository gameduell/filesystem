package filesystem;

import types.Data;

extern class File
{
	/// the filesystem creates files
	private function new() : Void;

	public var seekPosition (get, set) : Int;

	public function seekEndOfFile();

	public function writeFromData(data : Data);

	public function readIntoData(outputData : Data);

	public function close();
}