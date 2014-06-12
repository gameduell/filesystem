package filesystem;

import types.Data;

extern class FileReader
{
	/// the filesystem creates the filereader
	private function new() : Void;

	public var seekPosition (get, set) : Int;

	public function seekEndOfFile();

	public function readIntoData(outputData : Data);

	public function close();
}