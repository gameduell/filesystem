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

import flash.Lib;
import flash.events.IOErrorEvent;
import flash.events.Event;
import types.Data;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLLoaderDataFormat;
import flash.system.LoaderContext;

import flash.utils.ByteArray;

using StringTools;
using types.haxeinterop.DataBytesTools;

class FileSystem
{
    public var staticData: Map<String, Data>;
    public var cachedData: Map<String, Data>;
    public var tempData: Map<String, Data>;

    private static var requestsLeft: Int;
    private static var fileSystemInstance: FileSystem;

    private var staticDataURL: String = "static://";
    private var cachedDataURL: String = "cached://";
    private var tempDataURL: String = "temp://";

    public static inline function instance(): FileSystem
    {
        return fileSystemInstance;
    }

    public static function initialize(finishedCallback: Void -> Void): Void
    {
        if (fileSystemInstance == null)
        {
            fileSystemInstance = new FileSystem();
        }
        preloadStaticAssets(finishedCallback);
    }

    private function new(): Void
    {
        cachedData = new Map<String, Data>();
        tempData = new Map<String, Data>();
        staticData = new Map<String, Data>();
    }

    public function getFileList(url: String, ?recursive: Bool = true): Array<String>
    {
        if (url.startsWith(staticDataURL))
        {
            var withoutPrefix = trimURLPrefix(url);

            return getStaticFileList(withoutPrefix, recursive);
        }
        else
        {
            return []; ///unimplemented
        }
    }

    private function getStaticFileList(url: String, recursive: Bool): Array<String>
    {
        var filteredFiles = [];
        for (file in staticData.keys())
        {
            if (file.startsWith(url))
            {
                if (recursive || file.substr(url.length).indexOf("/") == -1)
                {
                    filteredFiles.push(staticDataURL + file);
                }
            }
        }

        return filteredFiles;
    }

	public function getUrlToStaticData() : String
	{
		return staticDataURL;
	}
	@:deprecated("urlToStaticData is deprecated. Use FileSystem.getUrlToStaticData() instead!")
	public function urlToStaticData() : String
	{
		return staticDataURL;
	}

	public function getUrlToCachedData() : String
	{
		return cachedDataURL;
	}
	@:deprecated("urlToCachedData is deprecated. Use FileSystem.getUrlToCachedData() instead!")
	public function urlToCachedData() : String
	{
		return cachedDataURL;
	}

	public function getUrlToTempData() : String
	{
		return tempDataURL;
	}
	@:deprecated("urlToTempData is deprecated. Use FileSystem.getUrlToTempData() instead!")
	public function urlToTempData() : String
	{
		return tempDataURL;
	}

    public function createFile(url: String): Bool
    {
        if (url.startsWith(staticDataURL))
        {
            return false;
        }

        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return false;
        }

        var withoutPrefix = trimURLPrefix(url);

        if (map.exists(withoutPrefix))
        {
            return false;
        }

        map[withoutPrefix] = new Data(0);
        return true;
    }

    public function getFileWriter(url: String): FileWriter
    {
        if (url.startsWith(staticDataURL))
        {
            return null;
        }

        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return null;
        }

        var withoutPrefix = trimURLPrefix(url);
        if (!map.exists(withoutPrefix))
        {
            return null;
        }

        var data = map[withoutPrefix];
        if (data == null) /// folder
        {
            return null;
        }

        return new FileWriter(data);
    }

    public function getFileReader(url: String): FileReader
    {
        var withoutPrefix = trimURLPrefix(url);
        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return null;
        }

        if (!map.exists(withoutPrefix))
        {
            return null;
        }

        var data = map[withoutPrefix];
        if (data == null) /// folder
        {
            return null;
        }

        return new FileReader(data);
    }

    public function createFolder(url: String): Bool
    {
        if (url.startsWith(staticDataURL))
        {
            return false;
        }

        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return false;
        }

        var withoutPrefix = trimURLPrefix(url);

        if (map.exists(withoutPrefix))
        {
            return false;
        }

        map[withoutPrefix] = null;
        return true;
    }

    public function deleteFile(url: String): Void
    {
        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return;
        }

        var withoutPrefix = trimURLPrefix(url);
        map.remove(withoutPrefix);
    }

    public function deleteFolder(url: String): Void
    {

        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return;
        }

        var withoutPrefix = trimURLPrefix(url);

        var toRemove = [];
        for (key in map.keys())
        {
            if (key.startsWith(withoutPrefix))
            {
                toRemove.push(key);
            }
        }

        for (key in toRemove)
        {
            map.remove(key);
        }

    }

    public function urlExists(url: String): Bool
    {
        if (isFolder(url))
        {
            return true;
        }

        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return false;
        }

        var withoutPrefix = trimURLPrefix(url);
        return map.exists(withoutPrefix);
    }

    public function isFolder(url: String): Bool
    {
        var map = getDataDictionaryBasedOnPrefix(url);

        var withoutPrefix = trimURLPrefix(url);

        if (map == staticData)
        {
            // we're working on static data
            if (StaticAssetList.folders.indexOf(withoutPrefix) != -1)
            {
                return true;
            }
        }
        else if (map != null)
        {
            if (map.exists(withoutPrefix) && map[withoutPrefix] == null)
            {
                return true;
            }
        }

        return false;
    }

    public function isFile(url: String): Bool
    {
        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return false;
        }

        var withoutPrefix = trimURLPrefix(url);
        return map.exists(withoutPrefix) && map[withoutPrefix] != null;
    }

    public function getFileSize(url: String): Int
    {
        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return 0;
        }

        var withoutPrefix = trimURLPrefix(url);

        if (!map.exists(withoutPrefix))
        {
            return 0;
        }

        return map[withoutPrefix].offsetLength;
    }

    public static function preloadStaticAssets(complete: Void -> Void): Void
    {
        if (filesystem.StaticAssetList.list.length == 0)
        {
            complete();
            return;
        }
        function encodeURLElement(element: String): String
        {
            return element.urlEncode();
        }
        requestsLeft = filesystem.StaticAssetList.list.length;
        function checkIfAvailableInResourcesAndAddtoFilesystem(fileName: String): Bool
        {
            var haxeBytes = haxe.Resource.getBytes(fileName);
            if(haxeBytes == null)
            {
                return false;
            }
            var data = haxeBytes.getTypesData();
            var correctedUrl: String = fileName.split("/").map(StringTools.urlEncode).join("/");
            FileSystem.instance().staticData[correctedUrl] = data;
            haxeBytes = null;
            return true;
        }
        for (val in filesystem.StaticAssetList.list)
        {
            if(checkIfAvailableInResourcesAndAddtoFilesystem(val))
            {
                requestsLeft--;
                if (requestsLeft == 0)
                {
                    complete();
                }
                continue;
            }
            var valWithAssets = "assets/" + val;
            valWithAssets.split("/").map(encodeURLElement).join("/");
            var loader: URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            var loaderContext: LoaderContext = new LoaderContext();

            loader.addEventListener(Event.COMPLETE, function(event: Event): Void
            {
                var bytes: ByteArray = event.target.data;
                var data = new Data(0);
                data.byteArray = bytes;

                var correctedUrl: String = val.split("/").map(StringTools.urlEncode).join("/");

                FileSystem.instance().staticData[correctedUrl] = data;

                requestsLeft--;
                if (requestsLeft == 0)
                {
                    complete();
                }
            });

            loader.addEventListener(IOErrorEvent.IO_ERROR, function(event: IOErrorEvent): Void
            {
                trace(event);
            });
            var req = new URLRequest(getBaseURL() + valWithAssets);
            loader.load(req);
        }
    }

    public function getData(url:String): Data
    {
        var map = getDataDictionaryBasedOnPrefix(url);

        if (map == null)
        {
            return null;
        }

        var withoutPrefix = trimURLPrefix(url);

        if (!map.exists(withoutPrefix))
        {
            return null;
        }

        return map[withoutPrefix];
    }

    /// HELPERS

    /**
    * If using relative URLs - the base URL of the root SWF is needed for loading assets properly
    */
    private static function getBaseURL(): String
    {
        var splitter = Lib.current.loaderInfo.url.split("/");
        splitter.pop();
        return splitter.join("/") + "/";
    }

    private function trimURLPrefix(url: String): String
    {
        var withoutPrefix = url.substr(url.indexOf(":") + 1);

        while (withoutPrefix.startsWith("/"))
        {
            withoutPrefix = withoutPrefix.substr(1);
        }
        return withoutPrefix;
    }

    private function getDataDictionaryBasedOnPrefix(url: String): Map<String, Data>
    {
        var withoutPrefix = trimURLPrefix(url);

        if (url.startsWith(staticDataURL))
        {
            return staticData;
        }
        else if (url.startsWith(cachedDataURL))
        {
            return cachedData;
        }
        else if (url.startsWith(tempDataURL))
        {
            return tempData;
        }

        return null;
    }

}
