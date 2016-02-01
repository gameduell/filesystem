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

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using duell.helpers.HashHelper;

import sys.io.Process;

using StringTools;

import haxe.io.Path;

typedef FileSystemHash = {
	PROCESSOR_HASH: Int,
	FOLDER_HASHES: Map<String, FolderHash>,
	HASH_VERSION: Int
}

typedef FolderHash = {
	FOLDER: String, /// relative to staging
	HASH: Int,
	ASSET_FOLDER: String /// path to the configured asset folder
}

@:access(duell.build.plugin.library.filesystem.AssetProcessorRegister)
class LibraryBuild
{
	private static inline var INTERNAL_ASSET_FOLDER = "assets";
	private static inline var HASH_VERSION = 1;

	private var hashPath: String;

	private var hash: FileSystemHash;
	private var previousHash: FileSystemHash;

	private var foldersThatChanged: Array<FolderHash> = [];

	private var previousProcessorHash: String = "";

	private var fullReset: Bool = false;

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

		generateCurrentHash();

		getCachedHash();

		compareHashes();

		if (Arguments.isDefineSet("forceAssetProcessing") || foldersThatChanged.length > 0)
		{
			LogHelper.info("[Filesystem] Assets changed! reprocessing");

			syncFilesInStagingArea();

			cleanUpIgnoredFiles();

			processFiles();

			cleanUpIgnoredFiles();

			saveHash();
		}
		else
		{
            if (!FileSystem.exists(AssetProcessorRegister.pathToTemporaryAssetArea))
            {
                PathHelper.mkdir(AssetProcessorRegister.pathToTemporaryAssetArea);
            }

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
		AssetProcessorRegister.pathToTemporaryAssetArea = Path.join([Configuration.getData().OUTPUT, "filesystem", INTERNAL_ASSET_FOLDER]);
		hashPath = Path.join([Configuration.getData().OUTPUT, "filesystem", "assetFolderHash.hash"]);
	}

	private function generateCurrentHash(): Void
	{
		hash = {
			PROCESSOR_HASH: HashHelper.getFnv32IntFromIntArray(AssetProcessorRegister.hashList),
			FOLDER_HASHES: new Map(),
			HASH_VERSION: HASH_VERSION
		};

		for(folder in LibraryConfiguration.getData().STATIC_ASSET_FOLDERS)
		{
			addHashOfFolderRecursively(folder);
		}
	}

	private function addHashOfFolderRecursively(folder: String): Void
	{
		var dirHash: Int = DirHashHelper.getHashOfDirectory(folder, LibraryConfiguration.getData().IGNORE_LIST);

		hash.FOLDER_HASHES.set(folder, {FOLDER: ".", HASH: dirHash, ASSET_FOLDER: folder});

		var folderList = PathHelper.getRecursiveFolderListUnderFolder(folder);
		for (innerFolder in folderList)
		{
			var dirHash: Int = DirHashHelper.getHashOfDirectory(
								Path.join([folder, innerFolder]),
								LibraryConfiguration.getData().IGNORE_LIST);

			hash.FOLDER_HASHES.set(Path.join([folder, innerFolder]), {
					FOLDER: innerFolder,
					HASH: dirHash,
					ASSET_FOLDER: folder
			});
		}
	}

	private function getCachedHash(): Void
	{
		if (FileSystem.exists(hashPath))
		{
	        var hashContent = File.getContent(hashPath);
	        previousHash = Json.parse(hashContent);

			if (Reflect.hasField(previousHash, "HASH_VERSION") &&
				previousHash.HASH_VERSION == HASH_VERSION)
			{
				/// finalize by transforming folder hashes into map
				var keyList = Reflect.fields(previousHash.FOLDER_HASHES);
				var map = new Map<String, FolderHash>();

				for (key in keyList)
				{
					map.set(key, Reflect.field(previousHash.FOLDER_HASHES, key));
				}

				previousHash.FOLDER_HASHES = map;

				return;
			}
		}

		previousHash = {
			PROCESSOR_HASH: 0,
			FOLDER_HASHES: new Map(),
			HASH_VERSION: HASH_VERSION
		}
	}

	private function compareHashes(): Void
	{
		if (hash.PROCESSOR_HASH != previousHash.PROCESSOR_HASH)
		{
			/// remake all the assets
			for (key in hash.FOLDER_HASHES.keys())
			{
				var folder = hash.FOLDER_HASHES.get(key).FOLDER;
				foldersThatChanged.push(hash.FOLDER_HASHES.get(key));
			}
		}
		else
		{
			for (key in hash.FOLDER_HASHES.keys())
			{
				if (previousHash.FOLDER_HASHES.exists(key))
				{
					if (previousHash.FOLDER_HASHES.get(key).HASH == hash.FOLDER_HASHES.get(key).HASH)
					{
						continue;
					}
					foldersThatChanged.push(hash.FOLDER_HASHES.get(key));
				}
			}
		}
	}

	private function deleteCachedHash(): Void
	{
		if (FileSystem.exists(hashPath))
		{
			FileSystem.deleteFile(hashPath);
		}
	}

	private function saveHash(): Void
	{
        if (FileSystem.exists(hashPath))
        {
            FileSystem.deleteFile(hashPath);
        }

        File.saveContent(hashPath, Json.stringify(hash));
	}

	private function syncFilesInStagingArea(): Void
	{
		var foldersToCheck: Map<String, Array<String>> = new Map(); /// path in staging to paths in asset folder

		for (folderHash in foldersThatChanged)
		{
			if (!foldersToCheck.exists(folderHash.FOLDER))
			{
				foldersToCheck.set(folderHash.FOLDER, []);
			}

			foldersToCheck.get(folderHash.FOLDER).push(folderHash.ASSET_FOLDER);
		}

		for (folderPath in foldersToCheck.keys())
		{
			var originFileList: Array<{FILE: String, ASSET_FOLDER: String}> = [];

			for (assetFolder in foldersToCheck.get(folderPath))
			{
				var fullOriginPath = Path.join([assetFolder, folderPath]);

				var newFileList = FileSystem.readDirectory(fullOriginPath);

				for (file in newFileList)
				{
					var fullFilePath = Path.join([fullOriginPath, file]);
					if (!FileSystem.isDirectory(fullFilePath))
					{
						originFileList.push({FILE: Path.join([folderPath, file]), ASSET_FOLDER: assetFolder});
					}
				}
			}

			var targetFolder = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, folderPath]);
			/// cleanup target folder
			if (FileSystem.exists(targetFolder))
			{
				var targetFileList = FileSystem.readDirectory(targetFolder);

				for (file in targetFileList)
				{
					var fullPath = Path.join([targetFolder, file]);
					if (!FileSystem.isDirectory(fullPath))
					{
						FileSystem.deleteFile(fullPath);
					}
				}
			}
			else
			{
				PathHelper.mkdir(targetFolder);
			}

			for (fileAnon in originFileList)
			{
				var originPath = Path.join([fileAnon.ASSET_FOLDER, fileAnon.FILE]);
				var targetPath = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, fileAnon.FILE]);
				FileHelper.copyIfNewer(originPath, targetPath);
			}
		}
	}

	private function cleanUpIgnoredFiles(): Void
	{
		var files = PathHelper.getRecursiveFileListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);
		for (file in files)
		{
			for (regex in LibraryConfiguration.getData().IGNORE_LIST)
			{
				if (regex.match(file))
				{
					var path = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]);
					if (FileSystem.exists(path))
					{
						/// we might have duplicate regex
						FileSystem.deleteFile(path);
					}
				}
			}
		}
	}

	private function processFiles(): Void
	{
		///fill folders that changed in the assetProcessorRegister
		var setMap: Map<String, Void> = new Map();
		for (folderHash in foldersThatChanged)
		{
			setMap.set(folderHash.FOLDER, null);
		}

		for (key in setMap.keys())
		{
			AssetProcessorRegister.foldersThatChanged.push(key + "/");
		}

		AssetProcessorRegister.process();
	}

	private function determineFileListFromAssetFolders() : Void
	{
		// add to subfolders
		var subfolders = PathHelper.getRecursiveFolderListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);
		LibraryConfiguration.getData().STATIC_ASSET_SUBFOLDERS = LibraryConfiguration.getData().STATIC_ASSET_SUBFOLDERS.concat(subfolders);

		// add to filenames
		var files = PathHelper.getRecursiveFileListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);

		for (file in files)
		{
			LibraryConfiguration.getData().STATIC_ASSET_FILENAMES.push(file);
		}
	}
	private function removeUnusedFiles(fileListToCopy: Array<String>, targetFolder: String): Void
	{
		if (!FileSystem.exists(targetFolder))
			return;

		/// get all the files in the Export folder
		var fileListFromPreviousBuild = PathHelper.getRecursiveFileListUnderFolder(targetFolder);

		/// remove the old and unneeded files
		for (oldFile in fileListFromPreviousBuild)
		{
			if(fileListToCopy.indexOf(oldFile) < 0 && FileSystem.exists(Path.join([targetFolder, oldFile])))
			{
				LogHelper.info('[FILESYSTEM] Removing unused file ' + oldFile);
				FileSystem.deleteFile(oldFile);
			}
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
		var targetFolder = Path.join([	Configuration.getData().OUTPUT,
										"ios",
										Configuration.getData().APP.FILE,
										INTERNAL_ASSET_FOLDER]);

		if (FileSystem.exists(targetFolder))
		{
			PathHelper.removeDirectory(targetFolder);
		}

		PathHelper.mkdir(targetFolder);
		FileHelper.recursiveCopyFiles(AssetProcessorRegister.pathToTemporaryAssetArea, targetFolder, true, true);
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

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([targetDirectory, Path.directory(file)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]), Path.join([targetDirectory, file]));
        }
		removeUnusedFiles(fileListToCopy, targetDirectory);
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

		if (LibraryConfiguration.getData().EMBED_ASSETS)
		{
			var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);

	        for (file in fileListToCopy)
	        {
				var destPath = Path.join([targetDirectory, file]);
				var origPath = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]);
	        	PathHelper.mkdir(Path.directory(destPath));
	        	FileHelper.copyIfNewer(origPath, destPath);

	        	/// Add files as resources to haxe arguments
	        	if(LibraryConfiguration.getData().EMBED_ASSETS)
	        	{
					LogHelper.info('[FILESYSTEM] Embedding html5 asset ' + destPath + "@" + file);
	        		Configuration.getData().HAXE_COMPILE_ARGS.push("-resource " + destPath + "@" + file);
	        	}
	        }
		}
		else
		{
			if (FileSystem.exists(targetDirectory))
			{
				PathHelper.removeDirectory(targetDirectory);
			}

			PathHelper.mkdir(targetDirectory);
			FileHelper.recursiveCopyFiles(AssetProcessorRegister.pathToTemporaryAssetArea, targetDirectory, true, true);
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

		var fileListToCopy = PathHelper.getRecursiveFileListUnderFolder(AssetProcessorRegister.pathToTemporaryAssetArea);

	    for (file in fileListToCopy)
	    {
			var destPath = Path.join([targetDirectory, file]);
			var origPath = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]);
	    	PathHelper.mkdir(Path.directory(destPath));
	    	FileHelper.copyIfNewer(origPath, destPath);

	    	/// Add files as resources to haxe arguments
	    	if(LibraryConfiguration.getData().EMBED_ASSETS)
	    	{
				LogHelper.info('[FILESYSTEM] Embedding flash asset ' + destPath + "@" + file);
	    		Configuration.getData().HAXE_COMPILE_ARGS.push("-resource " + destPath + "@" + file);
	    	}
	    }
		removeUnusedFiles(fileListToCopy, targetDirectory);
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
