package filesystem.modules;

import js.html.ArrayBuffer;

@:jsRequire('buffer', 'Buffer')
extern class Buffer
{
    var length(default, null) : Int;
    function new( size:Int );
    function readInt8( offset:Int, ?noAssert:Bool=false ) : Int;
    function writeInt8(value:Int, offset:Int, noAssert:Bool = false ) : Void;
}