package filesystem.modules;

extern class Buffer
{
    var length(default, null) : Int;
    function readInt8( offset:Int, ?noAssert:Bool=false ) : Int;
}