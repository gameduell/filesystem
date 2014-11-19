package filesystem;
import platform.Platform;

import types.Data;

using StringTools;

class FileSystem
{

    private function new() : Void
    {


    }

    public function getFileList(url : String, ?recursive : Bool = true) : Array<String>
    {
        return null;
    }

    private function getStaticFileList(url : String, recursive : Bool) : Array<String>
    {
        return null;
    }

    public function urlToStaticData() : String
    {
        return "";
    }

    public function urlToCachedData() : String
    {
        return "";
    }

    public function urlToTempData() : String
    {
        return "";
    }



    public function createFile(url : String) : Bool
    {
        return true;
    }

    public function getFileWriter(url : String) : FileWriter
    {
        return new FileWriter(null);
    }

    public function getFileReader(url : String) : FileReader
    {
        return new FileReader(null);
    }

    public function createFolder(url : String) : Bool
    {
        return true;
    }

    public function deleteFile(url : String) : Void
    {

    }

    public function deleteFolder(url : String) : Void
    {

    }

    public function urlExists(url : String) : Bool
    {
        return true;
    }

    public function isFolder(url : String) : Bool
    {
        return true;

    }

    public function isFile(url : String) : Bool
    {
        return true;
    }

/// SINGLETON

    static var fileSystemInstance : FileSystem;
    static public inline function instance() : FileSystem
    {
        if(fileSystemInstance == null)
        {
            fileSystemInstance = new FileSystem();
        }
        return fileSystemInstance;
    }

/// HELPERS

    private function trimURLPrefix(url : String) : String
    {
        var withoutPrefix = url.substr(url.indexOf(":") + 1);
        while(withoutPrefix.startsWith("/"))
            withoutPrefix = withoutPrefix.substr(1);
        return withoutPrefix;
    }

    private function getDataDictionaryBasedOnPrefix(url : String) : Map<String, Data>
    {
        return null;
    }

}

