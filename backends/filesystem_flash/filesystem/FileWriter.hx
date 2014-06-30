package filesystem;

import types.Data;

class FileWriter
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

    public function seekEndOfFile() :Void
    {
        currentSeekPosition = fileData.offsetLength;
    }

    public function writeFromData(data : Data) :Void
    {
        if(fileData.allocedLength < currentSeekPosition + data.offsetLength)
        {
            var partOfMemoryCovered = (fileData.allocedLength - currentSeekPosition);
            var extraMemoryNeeded = data.offsetLength - partOfMemoryCovered;
            fileData.resize(fileData.allocedLength + extraMemoryNeeded);
        }

        fileData.offset = currentSeekPosition;
        fileData.offsetLength = data.offsetLength;
        fileData.writeData(data);
    }

    public function close():Void
    {

    }
}
