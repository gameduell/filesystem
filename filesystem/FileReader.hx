package filesystem;

import types.Data;

extern class FileReader
{
	/// the filesystem creates the filereader
	private function new() : Void;

	public var seekPosition (get, set) : Int;

	public function seekEndOfFile(): Void;

	public function readIntoData(outputData : Data): Void;

	public function close(): Void;
}