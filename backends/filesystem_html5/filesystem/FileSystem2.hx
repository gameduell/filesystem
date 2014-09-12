package filesystem;

import types.Data;

using StringTools;

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
	public function urlToStaticData() : String
	{
		return staticDataURL;
	}

	private var cachedDataURL : String = "cached://";
	public function urlToCachedData() : String
	{
		return cachedDataURL;
	}

	private var tempDataURL : String = "temp://";
	public function urlToTempData() : String
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
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
			return false;

		var withoutPrefix = trimURLPrefix(url);
		return map.exists(withoutPrefix);
	}
	
	public function isFolder(url : String) : Bool
	{
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
			return false;

		var withoutPrefix = trimURLPrefix(url);
		return map.exists(withoutPrefix) && map[withoutPrefix] == null;
	}

	public function isFile(url : String) : Bool
	{
		var map = getDataDictionaryBasedOnPrefix(url);

		if(map == null)
			return false;

		var withoutPrefix = trimURLPrefix(url);
		return map.exists(withoutPrefix) && map[withoutPrefix] != null;
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

		for(val in filesystem.StaticAssetList.list)
		{
			requestsLeft += 1;
			var valWithAssets = "assets/"+val;
            valWithAssets.split("/").map(encodeURLElement).join("/");

			var oReq = new XMLHttpRequest();
			oReq.open("GET", valWithAssets, true);
			oReq.responseType = "arraybuffer";

			oReq.onload = function (oEvent) 
			{
				requestsLeft -= 1;
	  			var arrayBuffer = oReq.response;
	  			var data = new Data(0);
	  			data.arrayBuffer = arrayBuffer;

	  			FileSystem.instance().staticData[val.urlEncode()] = data;

	  			if(requestsLeft == 0)
	  			{
	  				complete();
	  			}
			};

			oReq.send(null);
		}
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

