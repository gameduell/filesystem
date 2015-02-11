/**
 * @autor kgar
 * @date 05.09.2014.
 * @company Gameduell GmbH
 */

package duell.build.plugin.library.filesystem;

import duell.build.plugin.library.filesystem.LibraryConfiguration;
import duell.build.plugin.platform.PlatformConfiguration;
import duell.build.objects.Configuration;

import duell.objects.DuellLib;
import duell.helpers.TemplateHelper;
import duell.helpers.FileHelper;
import duell.helpers.PathHelper;

import sys.io.Process;

using StringTools;

import haxe.io.Path;

class LibraryBuild
{
	private static inline var INTERNAL_ASSET_FOLDER = "assets";

	private var fileListToCopy: List<{fullPath : String, relativeFilePath : String}>;

	public function new ()
    {
		fileListToCopy = new List<{fullPath : String, relativeFilePath : String}>();
    }

	public function postParse() : Void
	{
		/// if no parsing is made we need to add the default state.
		if (Configuration.getData().LIBRARY.FILESYSTEM == null)
		{
			Configuration.getData().LIBRARY.FILESYSTEM = LibraryConfiguration.getData();
		}

		var haxeExtraSources = Path.join([Configuration.getData().OUTPUT,"haxe"]);
		if (Configuration.getData().SOURCES.indexOf(haxeExtraSources) == -1)
		{
			Configuration.getData().SOURCES.push(haxeExtraSources);
		}

		postParsePerPlatform();
	}

	public function preBuild() : Void
	{
		determineFileListFromAssetFolders();

		removeExcludedFiles();

		copyAssetListHaxeFile();

		preBuildPerPlatform();
	}

	private function determineFileListFromAssetFolders() : Void
	{
		for(folder in LibraryConfiguration.getData().STATIC_ASSET_FOLDERS)
		{
			var files = duell.helpers.PathHelper.getRecursiveFileListUnderFolder(folder);

			for (file in files)
			{
				fileListToCopy.push({fullPath : Path.join([folder, file]), relativeFilePath : file});
				LibraryConfiguration.getData().STATIC_ASSET_FILENAMES.push(file);
			}
		}
	}

	private function removeExcludedFiles(): Void
	{
		for (excludedPath in LibraryConfiguration.getData().EXCLUDE_ASSET_FILENAMES)
		{
			var regex: EReg = new EReg(regexifyPath(excludedPath), "i");

			for (pathObject in fileListToCopy)
			{
				if (regex.match(pathObject.fullPath))
				{
					LibraryConfiguration.getData().STATIC_ASSET_FILENAMES.remove(pathObject.relativeFilePath);
					fileListToCopy.remove(pathObject);
				}
			}
		}
	}

	private static function regexifyPath(path: String): String
	{
		// dots in filenames have to be escaped, otherwise they mean "any character"
		path = path.replace(".", "\\.");
		// asterisk is a wildcard for everything that comes before
		path = path.replace("*", ".*");

		// assume everything which is leading the path as a match
		return ".*" + path;
	}

	private function copyAssetListHaxeFile() : Void
	{
        var libPath : String = DuellLib.getDuellLib("filesystem").getPath();

        var exportPath : String = Path.join([Configuration.getData().OUTPUT, "haxe", "filesystem"]);

        var classSourcePath : String = Path.join([libPath,"template", "filesystem"]);

        TemplateHelper.recursiveCopyTemplatedFiles(classSourcePath, exportPath, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
	}
	
	public function postBuild() : Void
	{
		postBuildPerPlatform();
	}

	#if platform_ios

	private function postParsePerPlatform()
	{
		/// ADD ASSET FOLDER TO THE XCODE
		var assetFolderID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
		var fileID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
		PlatformConfiguration.getData().ADDL_PBX_BUILD_FILE.push('      ' + assetFolderID + ' /* $INTERNAL_ASSET_FOLDER in Resources */ = {isa = PBXBuildFile; fileRef = ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */; };');
		PlatformConfiguration.getData().ADDL_PBX_FILE_REFERENCE.push('      ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */ = {isa = PBXFileReference; lastKnownFileType = folder; name = $INTERNAL_ASSET_FOLDER; path = ' + Configuration.getData().APP.FILE + '/$INTERNAL_ASSET_FOLDER; sourceTree = \"<group>\"; };');
		PlatformConfiguration.getData().ADDL_PBX_RESOURCE_GROUP.push('            ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */,');			
		PlatformConfiguration.getData().ADDL_PBX_RESOURCES_BUILD_PHASE.push('            ' + assetFolderID + ' /* $INTERNAL_ASSET_FOLDER in Resources */,');
	}

	private function preBuildPerPlatform()
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "ios"]);
		var projectDirectory = Path.join([targetDirectory, Configuration.getData().APP.FILE]);

		var targetFolder = Path.join([projectDirectory, INTERNAL_ASSET_FOLDER]);
		PathHelper.mkdir(targetFolder);

        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([projectDirectory, INTERNAL_ASSET_FOLDER, Path.directory(file.relativeFilePath)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(file.fullPath, Path.join([projectDirectory, INTERNAL_ASSET_FOLDER, file.relativeFilePath]));
        }
	}

	private function postBuildPerPlatform()
	{

	}

    #elseif platform_macane

	private function postParsePerPlatform()
	{

	}

	private function preBuildPerPlatform()
	{

	}

	private function postBuildPerPlatform()
	{

	}

	#elseif platform_android

	private function postParsePerPlatform()
	{
	}

	private function preBuildPerPlatform()
	{

		/// currently not using the INTERNAL_ASSET_FOLDER, it goes directly into the assets folder.
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "android", "bin", "assets"]);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([targetDirectory, Path.directory(file.relativeFilePath)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(file.fullPath, Path.join([targetDirectory, file.relativeFilePath]));
        }
	}

	private function postBuildPerPlatform()
	{

	}

	#elseif platform_html5

	private function postParsePerPlatform()
	{
		
	}

	private function preBuildPerPlatform()
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "html5", "web"]);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([targetDirectory, INTERNAL_ASSET_FOLDER, Path.directory(file.relativeFilePath)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(file.fullPath, Path.join([targetDirectory, INTERNAL_ASSET_FOLDER, file.relativeFilePath]));
        }
	}

	private function postBuildPerPlatform()
	{

	}

	#elseif platform_flash

	private function postParsePerPlatform()
	{
		
	}

	private function preBuildPerPlatform()
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "flash", "web"]);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([targetDirectory, INTERNAL_ASSET_FOLDER, Path.directory(file.relativeFilePath)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(file.fullPath, Path.join([targetDirectory, INTERNAL_ASSET_FOLDER, file.relativeFilePath]));
        }
	}

	private function postBuildPerPlatform()
	{

	}

	#else

	private function postParsePerPlatform()
	{
		
	}

	private function preBuildPerPlatform()
	{
		
	}

	private function postBuildPerPlatform()
	{

	}


	#end
}