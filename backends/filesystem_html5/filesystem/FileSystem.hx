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

import types.Data;

using StringTools;
using types.haxeinterop.DataBytesTools;
import js.html.XMLHttpRequest;

class FileSystem
{

	public var staticData : Map<String, Data>;
	public var cachedData : Map<String, Data>;
	public var tempData : Map<String, Data>;
	private function new() : Void
	{

		staticData = new Map();
		cachedData = new Map();
		tempData = new Map();

	}

	public function getFileList(url : String, ?recursive : Bool = true) : Array<String>
	{
		if(url.startsWith(staticDataURL))
		{
			var withoutPrefix = trimURLPrefix(url);

			return getStaticFileList(withoutPrefix, recursive);
		}
		else
		{
			return []; ///unimplemented
		}
	}

	private function getStaticFileList(url : String, recursive : Bool) : Array<String>
	{
		var filteredFiles = [];
		for(file in staticData.keys())
		{
			if(file.startsWith(url))
			{
				if(recursive || file.substr(url.length).indexOf("/") == -1)
				filteredFiles.push(staticDataURL + file);
			}
		}

		return filteredFiles;
	}

	private var staticDataURL : String = "static://";
	public function getUrlToStaticData() : String
	{
		return staticDataURL;
	}

	private var cachedDataURL : String = "cached://";
	public function getUrlToCachedData() : String
	{
		return cachedDataURL;
	}

	private var tempDataURL : String = "temp://";
	public function getUrlToTempData() : String
	{
		return tempDataURL;
	}



	public function createFile(url : String) : Bool
	{
		if(url.startsWith(staticDataURL))
		return false;

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return false;

		var withoutPrefix = trimURLPrefix(url);

		if(map.exists(withoutPrefix))
		return false;

		map[withoutPrefix] = new Data(0);
		return true;
	}

	public function getFileWriter(url : String) : FileWriter
	{
		if(url.startsWith(staticDataURL))
		return null;

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return null;

		var withoutPrefix = trimURLPrefix(url);
		if(!map.exists(withoutPrefix))
		return null;

		var data = map[withoutPrefix];
		if(data == null) /// folder
		return null;

		return new FileWriter(data);
	}

	public function getFileReader(url : String) : FileReader
	{
		var withoutPrefix = trimURLPrefix(url);

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return null;

		if(!map.exists(withoutPrefix))
		return null;

		var data = map[withoutPrefix];
		if(data == null) /// folder
		return null;

		return new FileReader(data);
	}

	public function createFolder(url : String) : Bool
	{
		if(url.startsWith(staticDataURL))
		return false;

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return false;

		var withoutPrefix = trimURLPrefix(url);

		if(map.exists(withoutPrefix))
		return false;

		map[withoutPrefix] = null;
		return true;
	}

	public function deleteFile(url : String) : Void
	{
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return;

		var withoutPrefix = trimURLPrefix(url);
		map.remove(withoutPrefix);
	}

	public function deleteFolder(url : String) : Void
	{

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return;

		var withoutPrefix = trimURLPrefix(url);

		var toRemove = [];
		for(key in map.keys())
		{
			if(key.startsWith(withoutPrefix))
			toRemove.push(key);
		}

		for(key in toRemove)
		{
			map.remove(key);
		}

	}

	public function urlExists(url : String) : Bool
	{
		if (isFolder(url))
		{
			return true;
		}

		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return false;

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

	public function isFile(url : String) : Bool
	{
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return false;

		var withoutPrefix = trimURLPrefix(url);
		return map.exists(withoutPrefix) && map[withoutPrefix] != null;
	}

	public function getFileSize(url : String) : Int
	{
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
		return 0;

		var withoutPrefix = trimURLPrefix(url);

		if (!map.exists(withoutPrefix))
		return 0;

		return map[withoutPrefix].allocedLength;
	}

	/// SINGLETON
	static var fileSystemInstance : FileSystem;
	static public inline function instance() : FileSystem
	{
		return fileSystemInstance;
	}

	public static function initialize(finishedCallback : Void -> Void):Void
	{

		if(fileSystemInstance == null)
		{
			fileSystemInstance = new FileSystem();
		}
		preloadStaticAssets(finishedCallback);
	}

	static private var requestsLeft : Int;
	public static function preloadStaticAssets(complete : Void -> Void) : Void
	{

		if(filesystem.StaticAssetList.list.length == 0)
		{
			complete();
			return;
		}

		requestsLeft = 0;

		function encodeURLElement(element:String) : String
		{
			return element.urlEncode();
		}

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

		for(val in filesystem.StaticAssetList.list)
		{
			if(checkIfAvailableInResourcesAndAddtoFilesystem(val))
			{
				continue;
			}
			requestsLeft += 1;
			var valWithAssets = getBaseURL()+"assets/"+val;
			valWithAssets.split("/").map(encodeURLElement).join("/");

			var oReq = new XMLHttpRequest();
			oReq.open("GET", valWithAssets, true);
			oReq.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;

			oReq.onload = function (oEvent)
			{
				requestsLeft -= 1;
				var arrayBuffer = oReq.response;
				var data = new Data(0);
				data.arrayBuffer = arrayBuffer;

				var correctedUrl: String = val.split("/").map(StringTools.urlEncode).join("/");

				FileSystem.instance().staticData[correctedUrl] = data;

				if(requestsLeft == 0)
				{
					complete();
				}
			};

			oReq.send(null);
		}

		if(requestsLeft == 0)
		{
			complete();
		}
	}

	public static function getBaseURL()
	{
		var location: js.html.Location =  js.Browser.location;
		var url = location.href;  // entire url including querystring - also: window.location.href;
		var baseURL = url.substring(0, url.indexOf('/', 14));

		// Root Url for domain name
		return baseURL + "/";

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

	private function trimURLPrefix(url : String) : String
	{
		var withoutPrefix = url.substr(url.indexOf(":") + 1);
		while(withoutPrefix.startsWith("/"))
		withoutPrefix = withoutPrefix.substr(1);
		return withoutPrefix;
	}

	private function getDataDictionaryBasedOnPrefix(url : String) : Map<String, Data>
	{
		var withoutPrefix = trimURLPrefix(url);
		if(url.startsWith(staticDataURL))
		{
			return staticData;
		}
		else if(url.startsWith(cachedDataURL))
		{
			return cachedData;
		}
		else if(url.startsWith(tempDataURL))
		{
			return tempData;
		}

		return null;
	}
}
