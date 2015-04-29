/**
 * @autor kgar
 * @date 05.09.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.library.filesystem;

import haxe.io.Path;

typedef KeyValueArray = Array<{NAME : String, VALUE : String}>;

typedef LibraryConfigurationData = {
	STATIC_ASSET_FOLDERS : Array<String>,
	EXCLUDE_ASSET_FILENAMES: Array<String>,
	EMBED_ASSETS: Bool,

	/// GENERATED BY PARSING FILE NAMES FROM THE STATIC_ASSETS
	STATIC_ASSET_FILENAMES : Array<String>,
    STATIC_ASSET_SUBFOLDERS : Array<String>
}

class LibraryConfiguration
{
	public static var _configuration : LibraryConfigurationData = null;
	private static var _parsingDefines : Array<String> = ["filesystem"];
	public static function getData() : LibraryConfigurationData
	{
		if (_configuration == null)
			initConfig();
		return _configuration;
	}

	public static function getConfigParsingDefines() : Array<String>
	{
		return _parsingDefines;
	}

	public static function addParsingDefine(str : String)
	{
		_parsingDefines.push(str);
	}

	private static function initConfig()
	{
		_configuration = 
		{
			STATIC_ASSET_FOLDERS : [],
			EXCLUDE_ASSET_FILENAMES : [],
			EMBED_ASSETS: false,
			STATIC_ASSET_FILENAMES : [],
            STATIC_ASSET_SUBFOLDERS : []
		};
	}
}