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

package filesystem;

import filesystem.modules.FS;
import filesystem.modules.Stats;
import filesystem.modules.Path;
import filesystem.modules.Buffer;

import js.html.ArrayBuffer;
import js.html.DataView;

import types.Data;

using StringTools;

class FileSystem
{

    private static var fsInstance : FileSystem;

    public static function initialize(finishedCallback : Void->Void ):Void
    {
        if(finishedCallback != null)
            finishedCallback();
    }

    public static function instance() : FileSystem
    {
        if (fsInstance == null)
            fsInstance = new FileSystem();

        return fsInstance;
    }


    private var staticDataPath : String = null;
    private var tempDataPath : String = null;
    private var cachedDataPath : String = null;

    private function new(){
        staticDataPath = untyped __dirname;
        staticDataPath = Path.join(staticDataPath, "assets");

        tempDataPath = untyped __dirname;
        tempDataPath = Path.join(tempDataPath, "tmp");

        cachedDataPath = untyped __dirname;
        cachedDataPath = Path.join(cachedDataPath, "cached");
    }


    public function getUrlToStaticData() : String
    {
        return staticDataPath;
    }

    public function getUrlToCachedData() : String
    {
        return cachedDataPath;
    }

    public function getUrlToTempData() : String
    {
        return tempDataPath;
    }

    public function getFileWriter(url : String) : FileWriter
    {
        try
        {
            url = url.urlDecode();

            var rawBuffer = FS.readFileSync( url );
            var data = new Data(rawBuffer.length);
            var v = convert( rawBuffer );
            data.arrayBuffer = v.buffer;

            return new FileWriter( data );
        }
        catch(e : Dynamic)
        {
            trace("Error in FileSystem::getFileWriter : " + e);
        }

        return new FileWriter(new Data(0));
    }

    private function convert( buf:Buffer ) : DataView
    {
        var ab = new ArrayBuffer(buf.length);
        var view = new DataView(ab);
        var length = buf.length;
        for (i in 0...length)
        {
            view.setInt8(i, buf.readInt8(i));
        }

        return view;
    }

    public function getFileReader(url : String) : FileReader
    {
        try
        {
            url = url.urlDecode();

            var rawBuffer = FS.readFileSync( url );
            var data = new Data(rawBuffer.length);
            var v = convert( rawBuffer );
            data.arrayBuffer = v.buffer;

            return new FileReader( data );
        }
        catch(e : Dynamic)
        {
            trace("Error in FileSystem::getFileReader : " + e);
        }

        return new FileReader(new Data(0));
    }

    public function createFile(url : String) : Bool
    {
        try
        {
            url = url.urlDecode();

            FS.writeFileSync( url.urlDecode(), "" );
        }
        catch(e : Dynamic)
        {
            return false;
        }

        return true;
    }

    public function createFolder(url : String) : Bool
    {
        url = url.urlDecode();
        if( !Path.isAbsolute(url) )
        {
            var workingDir = untyped __dirname;
            url = Path.join( workingDir, url );
        }

        var parts = url.split( Path.sep );
        var path = "";
        for ( p in parts )
        {
            if( p == "") continue;

            path += Path.sep + p;
            if( !urlExists( path ) )
            {
                if( !mkdir( path ) )
                    return false;
            }
        }

        return true;
    }

    private function mkdir( path:String ) : Bool
    {
        try
        {
            FS.mkdirSync( path.urlDecode() );
        }
        catch(e : Dynamic)
        {
            trace(e);
            return false;
        }

        return true;
    }

    public function urlExists(url : String) : Bool
    {
        try
        {
            var stats = FS.statSync( url.urlDecode() );
            return stats.isDirectory() || stats.isFile();
        }
        catch(e : Dynamic)
        {
            return false;
        }
    }

    public function isFolder(url : String) : Bool
    {
        try
        {
            var stats = FS.statSync( url.urlDecode() );
            return stats.isDirectory();
        }
        catch(e : Dynamic)
        {
            return false;
        }
    }

    public function isFile(url : String) : Bool
    {
        try
        {
            url = url.urlDecode();

            var stats = FS.statSync( url.urlDecode() );
            return stats.isFile();
        }
        catch(e : Dynamic)
        {
            return false;
        }
    }

    public function getFileSize(url : String) : Int
    {
        try
        {
            var stats = FS.statSync( url.urlDecode() );
            return Reflect.field(stats, "size");
        }
        catch(e : Dynamic)
        {
            trace(e);
            return 0;
        }
    }

    public function deleteFile(url : String) : Void
    {
        try
        {
            FS.unlinkSync( url.urlDecode() );
        }
        catch(e : Dynamic)
        {}
    }

    /**
        function deleteFolder
        @param url String
        
        NodeJS doesn't support recursive deletion or deletion
        of not empty folders. This function provides this
        functionallity.
    */
    public function deleteFolder(url : String) : Void
    {
        try
        {
            url = url.urlDecode();

            var files = FS.readdirSync( url );
            for ( c in files )
            {
                var path = Path.join( url, c );
                var stats = FS.statSync( path );
                if( stats.isDirectory() )
                {
                    deleteFolder( path ); //check current folder for files
                }
                else
                {
                    FS.unlinkSync( path );//remove file
                }
                
            }

            FS.rmdirSync( url );//remove folder
        }
        catch(e : Dynamic)
        {
            trace('Error :: deleteFolder :: ' + e);
        }
    }

    /** function normalize
        @param path String
        @return String

        Decodes the passed url and replaces spaces by a valid character
        as long as spaces are not supported on filesystems.
    */
    private function normalize( path : String ) : String
    {
        var regEx = ~/ /g;
        return regEx.replace( path.urlDecode(), '_' );
    }
}