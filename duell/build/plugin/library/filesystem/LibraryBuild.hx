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

import duell.build.plugin.library.filesystem.platform.IPlatformBuild;
import duell.build.plugin.library.filesystem.platform.NoSupportedPlatform;

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
	private var fullRebuild: Bool = false; /// set if the config hash changes, or if forceAssetProcessing

	private var previousProcessorHash: String = "";

	private var fullReset: Bool = false;

	private var platformBuild : IPlatformBuild;

	public function new () {

		#if platform_ios
			platformBuild = new duell.build.plugin.library.filesystem.platform.IOSBuild( INTERNAL_ASSET_FOLDER );
		#elseif platform_android
			platformBuild = new duell.build.plugin.library.filesystem.platform.AndroidBuild();
		#elseif platform_html5
			platformBuild = new duell.build.plugin.library.filesystem.platform.HTML5Build( INTERNAL_ASSET_FOLDER );
		#elseif platform_electron
			platformBuild = new duell.build.plugin.library.filesystem.platform.ElectronBuild( INTERNAL_ASSET_FOLDER );
		#else
			platformBuild = new NoSupportedPlatform();
		#end
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

	public function postPostParse(): Void
	{
		#if (!platform_ios && !platform_android && !platform_html5 && !platform_electron)
		return;
		#end

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
		if (hash.PROCESSOR_HASH != previousHash.PROCESSOR_HASH || Arguments.isDefineSet("forceAssetProcessing"))
		{
			/// remake all the assets
			for (key in hash.FOLDER_HASHES.keys())
			{
				var folder = hash.FOLDER_HASHES.get(key).FOLDER;
				foldersThatChanged.push(hash.FOLDER_HASHES.get(key));
			}

			fullRebuild = true;
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
				else
				{
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

		AssetProcessorRegister.fullRebuild = fullRebuild;

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
			var fullPath = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]);
			var stat = python.lib.Os.stat(fullPath);
			LibraryConfiguration.getData().STATIC_ASSET_HASHES.push("" + stat.st_size + "" + stat.st_mtime);
			LibraryConfiguration.getData().STATIC_ASSET_FILENAMES.push(file);
		}
	}

	private function postParsePerPlatform(): Void
	{
		platformBuild.postParsePerPlatform();
	}

	private function postPostParsePerPlatform(): Void
	{
		platformBuild.postPostParsePerPlatform();
	}

	private function preBuildPerPlatform(): Void
	{
		platformBuild.preBuildPerPlatform();
	}

	private function postBuildPerPlatform(): Void
	{
		platformBuild.postBuildPerPlatform();
	}
}
