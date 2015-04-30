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
import duell.helpers.LogHelper;
import duell.helpers.DirHashHelper;
import duell.objects.Arguments;

import sys.FileSystem;
import sys.io.File;

using duell.helpers.HashHelper;

import sys.io.Process;

using StringTools;

import haxe.io.Path;

class LibraryBuild
{
	public static var pathToTemporaryAssetArea: String = null; /// will be set after post

	private static inline var INTERNAL_ASSET_FOLDER = "assets";

	private var hashPath: String;

	public function new () {}

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

	public function postPostParse(): Void
	{
		generateVariables();

		var currentHash = generateCurrentHash();

		var previousHash = getCachedHash();

		if (Arguments.isDefineSet("forceAssetProcessing") || currentHash != previousHash)
		{
			LogHelper.info("", "[Filesystem] Assets changed! reprocessing");

			if (FileSystem.exists(pathToTemporaryAssetArea))
			{
				PathHelper.removeDirectory(pathToTemporaryAssetArea);
			}

			PathHelper.mkdir(pathToTemporaryAssetArea);

			copyFilesToStagingArea();

			cleanUpIgnoredFiles();

			processFiles();

			saveHash(currentHash);
		}
		else
		{
			LogHelper.info("", "[Filesystem] no asset change! bypassing the processing");
		}

	    postPostParsePerPlatform();
	}

	public function preBuild() : Void
	{
		determineFileListFromAssetFolders();

		copyAssetListHaxeFile();

		preBuildPerPlatform();
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

	public function clean(): Void
	{
		generateVariables();

		deleteCachedHash();
	}

	private function generateVariables(): Void
	{
		pathToTemporaryAssetArea = Path.join([Configuration.getData().OUTPUT, "filesystem", INTERNAL_ASSET_FOLDER]);
		hashPath = Path.join([Configuration.getData().OUTPUT, "filesystem", "assetFolderHash.hash"]);
	}


	private function generateCurrentHash(): Int
	{
		var arrayOfHashes = [];
		for(folder in LibraryConfiguration.getData().STATIC_ASSET_FOLDERS)
		{
			addHashOfFolderRecursively(arrayOfHashes, folder);
		}

		arrayOfHashes = arrayOfHashes.concat(AssetProcessorRegister.hashList);

		return arrayOfHashes.getFnv32IntFromIntArray();
	}

	private function addHashOfFolderRecursively(arrayOfHashes: Array<Int>, folder): Void
	{
		var hash: Int = DirHashHelper.getHashOfDirectory(folder);
		arrayOfHashes.push(hash);

		var folderList = PathHelper.getRecursiveFolderListUnderFolder(folder);
		for (innerFolder in folderList)
		{
			addHashOfFolderRecursively(arrayOfHashes, Path.join([folder, innerFolder]));
		}
	}

	private function getCachedHash(): Int
	{
		if (FileSystem.exists(hashPath))
		{
            var hash: String = File.getContent(hashPath);

            return Std.parseInt(hash);
		}
		return 0;
	}

	private function deleteCachedHash(): Void
	{
		if (FileSystem.exists(hashPath))
		{
			FileSystem.deleteFile(hashPath);
		}
	}

	private function saveHash(hash: Int): Void
	{
        if (FileSystem.exists(hashPath))
        {
            FileSystem.deleteFile(hashPath);
        }

        File.saveContent(hashPath, Std.string(hash));
	}

	private function copyFilesToStagingArea(): Void
	{
		for(folder in LibraryConfiguration.getData().STATIC_ASSET_FOLDERS)
		{
			if(folder == null)
				return;

			FileHelper.recursiveCopyFiles(folder, pathToTemporaryAssetArea);
		}
	}

	private function cleanUpIgnoredFiles(): Void
	{
		var files = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);
		for (file in files)
		{
			for (regex in LibraryConfiguration.getData().IGNORE_LIST)
			{
				if (regex.match(file))
				{
					FileSystem.deleteFile(Path.join([pathToTemporaryAssetArea, file]));
				}
			}
		}
	}

	private function processFiles(): Void
	{
		AssetProcessorRegister.process();
	}

	private function determineFileListFromAssetFolders() : Void
	{
		// add to subfolders
		var subfolders = PathHelper.getRecursiveFolderListUnderFolder(pathToTemporaryAssetArea);
		LibraryConfiguration.getData().STATIC_ASSET_SUBFOLDERS = LibraryConfiguration.getData().STATIC_ASSET_SUBFOLDERS.concat(subfolders);

		// add to filenames
		var files = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);

		for (file in files)
		{
			LibraryConfiguration.getData().STATIC_ASSET_FILENAMES.push(file);
		}
	}

	#if platform_ios

	private function postParsePerPlatform(): Void
	{
		/// ADD ASSET FOLDER TO THE XCODE
		var assetFolderID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
		var fileID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
		PlatformConfiguration.getData().ADDL_PBX_BUILD_FILE.push('      ' + assetFolderID + ' /* $INTERNAL_ASSET_FOLDER in Resources */ = {isa = PBXBuildFile; fileRef = ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */; };');
		PlatformConfiguration.getData().ADDL_PBX_FILE_REFERENCE.push('      ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */ = {isa = PBXFileReference; lastKnownFileType = folder; name = $INTERNAL_ASSET_FOLDER; path = ' + Configuration.getData().APP.FILE + '/$INTERNAL_ASSET_FOLDER; sourceTree = \"<group>\"; };');
		PlatformConfiguration.getData().ADDL_PBX_RESOURCE_GROUP.push('            ' + fileID + ' /* $INTERNAL_ASSET_FOLDER */,');
		PlatformConfiguration.getData().ADDL_PBX_RESOURCES_BUILD_PHASE.push('            ' + assetFolderID + ' /* $INTERNAL_ASSET_FOLDER in Resources */,');
	}

	private function postPostParsePerPlatform():Void
	{
	}
	private function preBuildPerPlatform()
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "ios"]);
		var projectDirectory = Path.join([targetDirectory, Configuration.getData().APP.FILE]);

		var targetFolder = Path.join([projectDirectory, INTERNAL_ASSET_FOLDER]);
		PathHelper.mkdir(targetFolder);

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([projectDirectory, INTERNAL_ASSET_FOLDER, Path.directory(file)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(Path.join([pathToTemporaryAssetArea, file]), Path.join([projectDirectory, INTERNAL_ASSET_FOLDER, file]));
        }
	}

	private function postBuildPerPlatform(): Void
	{

	}

	#elseif platform_android

	private function postParsePerPlatform(): Void
	{
	}
	private function postPostParsePerPlatform():Void
	{
	}

	private function preBuildPerPlatform(): Void
	{

		/// currently not using the INTERNAL_ASSET_FOLDER, it goes directly into the assets folder.
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "android", "bin", "assets"]);

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([targetDirectory, Path.directory(file)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(Path.join([pathToTemporaryAssetArea, file]), Path.join([targetDirectory, file]));
        }
	}

	private function postBuildPerPlatform(): Void
	{

	}

	#elseif platform_html5
	private function postParsePerPlatform(): Void
	{
	}
	private function postPostParsePerPlatform():Void
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "html5", "web", INTERNAL_ASSET_FOLDER]);

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);

        for (file in fileListToCopy)
        {
			var destPath = Path.join([targetDirectory, file]);
			var origPath = Path.join([pathToTemporaryAssetArea, file]);
        	PathHelper.mkdir(Path.directory(file));
        	FileHelper.copyIfNewer(origPath, destPath);

        	/// Add files as resources to haxe arguments
        	if(LibraryConfiguration.getData().EMBED_ASSETS)
        	{
				LogHelper.info('[FILESYSTEM] Embedding html5 asset ' + destPath + "@" + file);
        		Configuration.getData().HAXE_COMPILE_ARGS.push("-resource " + destPath + "@" + file);
        	}
        }
	}

	private function preBuildPerPlatform(): Void
	{
    }

	private function postBuildPerPlatform(): Void
	{

	}

	#elseif platform_flash

	private function postParsePerPlatform(): Void
	{
	}

	private function postPostParsePerPlatform():Void
	{
		var targetDirectory = Path.join([Configuration.getData().OUTPUT, "flash", "web", INTERNAL_ASSET_FOLDER]);

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(pathToTemporaryAssetArea);

	    for (file in fileListToCopy)
	    {
			var destPath = Path.join([targetDirectory, file]);
			var origPath = Path.join([pathToTemporaryAssetArea, file]);
	    	PathHelper.mkdir(Path.directory(file));
	    	FileHelper.copyIfNewer(origPath, destPath);

	    	/// Add files as resources to haxe arguments
	    	if(LibraryConfiguration.getData().EMBED_ASSETS)
	    	{
				LogHelper.info('[FILESYSTEM] Embedding flash asset ' + destPath + "@" + file);
	    		Configuration.getData().HAXE_COMPILE_ARGS.push("-resource " + destPath + "@" + file);
	    	}
	    }
	}

	private function preBuildPerPlatform(): Void
	{
	}

	private function postBuildPerPlatform(): Void
	{

	}

	#else

	private function postParsePerPlatform(): Void
	{

	}
	private function postPostParsePerPlatform(): Void
	{

	}
	private function preBuildPerPlatform(): Void
	{

	}

	private function postBuildPerPlatform(): Void
	{

	}


	#end
}
