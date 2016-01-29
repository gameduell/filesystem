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

import haxe.io.Path;

import filesystem.modules.FS;
import filesystem.modules.Stats;

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

    private function new(){
        staticDataPath = untyped __dirname;
    }


    public function getUrlToStaticData() : String
    {
        return Path.join([staticDataPath, "assets"]);
    }

    public function getUrlToCachedData() : String
    {
        return "";
    }

    public function getUrlToTempData() : String
    {
        return "";
    }

    public function getFileWriter(url : String) : FileWriter
    {
        return new FileWriter();
    }

    public function getFileReader(url : String) : FileReader
    {
        return new FileReader();
    }

    public function createFile(url : String) : Bool
    {
        try
        {
            FS.writeFileSync( url, "" );
        }
        catch(e : Dynamic)
        {
            return false;
        }

        return true;
    }

    public function createFolder(url : String) : Bool
    {
        try
        {
            FS.mkdirSync(url);
        }
        catch(e : Dynamic)
        {
            return false;
        }

        return true;
    }

    public function urlExists(url : String) : Bool
    {
        try
        {
            var stats = FS.statSync( url );
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
            var stats = FS.statSync( url );
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
            var stats = FS.statSync( url );
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
            var stats = FS.statSync( url );
            return Reflect.field(stats, "size");
        }
        catch(e : Dynamic)
        {
            return 0;
        }
    }

    public function deleteFile(url : String) : Void
    {
        try
        {
            FS.unlinkSync( url );
        }
        catch(e : Dynamic)
        {
            throw ('Deletion of file "$url" failed!');
        }
        
    }

    public function deleteFolder(url : String) : Void
    {
        try
        {
            FS.rmdirSync( url );
        }
        catch(e : Dynamic)
        {
            throw ('Deletion of directory "$url" failed!');
        }
    }
}