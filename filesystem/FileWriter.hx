package filesystem;

import types.Data;

extern class FileWriter
{
	/// the filesystem creates the filewriter
	private function new() : Void;

	public var seekPosition (get, set) : Int;

	public function writeFromData(data : Data): Void;

	public function close(): Void;
}