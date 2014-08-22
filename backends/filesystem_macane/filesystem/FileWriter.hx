package filesystem;

import types.Data;

class FileWriter
{

    private var fileData : Data;

    public function new(d : Data)
    {
        fileData = d;
    }

    public function get_seekPosition () : Int
    {
        return 0;
    }

    public function set_seekPosition (val : Int) : Int
    {
        return 0;
    }

    public function seekEndOfFile() :Void
    {
    }

    public function writeFromData(data : Data) :Void
    {

    }

    public function close():Void
    {

    }
}
