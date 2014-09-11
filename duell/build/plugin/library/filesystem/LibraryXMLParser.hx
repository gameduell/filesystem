/**
 * @autor kgar
 * @date 05.09.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.library.filesystem;

import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;

import duell.build.plugin.library.filesystem.LibraryConfiguration;

import duell.helpers.XMLHelper;
import duell.helpers.LogHelper;

import haxe.xml.Fast;

class LibraryXMLParser
{
	public static function parse(xml : Fast) : Void
	{
		Configuration.getData().LIBRARY.FILESYSTEM = LibraryConfiguration.getData();

		for (element in xml.elements) 
		{
			if (!XMLHelper.isValidElement(element, DuellProjectXML.getConfig().parsingConditions))
				continue;

			switch(element.name)
			{
				case 'static-assets':
					parseStaticAssetsElement(element);
			}
		}
	}

	private static function parseStaticAssetsElement(element : Fast)
	{
		if (element.has.path)
		{
			LibraryConfiguration.getData().STATIC_ASSET_FOLDERS.push(resolvePath(element.att.path));
		}
	}

	/// HELPERS
	private static function addUniqueKeyValueToKeyValueArray(keyValueArray : KeyValueArray, key : String, value : String)
	{
		for (keyValuePair in keyValueArray)
		{
			if (keyValuePair.NAME == key)
			{
				LogHelper.println('Overriting key $key value ${keyValuePair.VALUE} with value $value');
				keyValuePair.VALUE = value;
			}
		}

		keyValueArray.push({NAME : key, VALUE : value});
	}

	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}
}