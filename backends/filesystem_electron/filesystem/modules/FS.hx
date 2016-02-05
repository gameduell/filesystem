/*
* Copyright (c) 2003-2015, GameDuell GmbH
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice,
* this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package filesystem.modules;

@:jsRequire("fs")
extern class FS
{
    static function appendFileSync( path:String, data:Dynamic, ?options:Dynamic ) : Void;
    static function readdirSync( path:String ) : Array<String>;
    static function stat( path:String, callback:Dynamic -> Stats -> Void ) : Bool;
    static function readFileSync( path:String, ?opts:Dynamic) : Buffer;
    static function statSync( path:String) : Stats;
    static function unlinkSync( path:String) : Dynamic;
    static function rmdirSync( path:String) : Dynamic;
    static function mkdirSync( path:String, mode:String='0o777') : Void;
    static function writeFileSync( path:String, data:Dynamic, ?options:Dynamic) : Dynamic;
}
