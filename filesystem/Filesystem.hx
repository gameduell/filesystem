package filesystem;

import platform.Platform;

import types.Data;

using StringTools;

class Filesystem
{

	public var staticData : Map<String, Data>;
	public var cachedData : Map<String, Data>;
	public var tempData : Map<String, Data>;
	private function new() : Void
	{
		Platform.initialize();

		staticData = Platform.instance().staticAssetData;
		
		cachedData = new Map<String, Data>();
		tempData = new Map<String, Data>();

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

	static var fileSystemInstance : Filesystem;
	static public inline function instance() : Filesystem
	{
		if(fileSystemInstance == null)
		{
			fileSystemInstance = new Filesystem();
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

