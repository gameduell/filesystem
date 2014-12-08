package filesystem;

import types.Data;

class FileReader
{

	private var fileData : Data;

	private var currentSeekPosition = 0;
	public var seekPosition (get, set) : Int;

	public function new(d : Data)
	{
		fileData = d;
	}

	public function get_seekPosition () : Int
	{
		return currentSeekPosition;
	}

	public function set_seekPosition (val : Int) : Int
	{
		currentSeekPosition = val;
		return currentSeekPosition;
	}

	public function readIntoData(data : Data)
	{
		fileData.offset = currentSeekPosition;
		fileData.offsetLength = data.offsetLength;
		data.writeData(fileData);
	}
	
	public function close()
	{

	}
}
