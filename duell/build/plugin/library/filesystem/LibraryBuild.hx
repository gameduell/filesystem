/**
 * @autor kgar
 * @date 05.09.2014.
 * @company Gameduell GmbH
 */

package duell.build.plugin.library.filesystem;

import duell.build.plugin.library.filesystem.LibraryConfiguration;

import duell.build.plugin.platform.PlatformConfiguration;

/*
import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;
import duell.build.helpers.TemplateHelper;
import duell.build.helpers.XCodeHelper;

import duell.helpers.LogHelper;
import duell.helpers.ProcessHelper;

import duell.objects.DuellLib;
import duell.objects.Haxelib;

import sys.FileSystem;
import haxe.io.Path;
*/
import duell.build.objects.Configuration;

import duell.objects.DuellLib;
import duell.helpers.TemplateHelper;
import duell.helpers.FileHelper;
import duell.helpers.PathHelper;

import sys.io.Process;

import haxe.io.Path;

class LibraryBuild
{
	private var fileListToCopy : Array<{fullPath : String, relativeFilePath : String}> = [];
    public function new ()
    {
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

		determineFileListFromAssetFolders();

		postParsePerPlatform();
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
	
	public function preBuild() : Void
	{
		copyAssetListHaxeFile();

		preBuildPerPlatform();
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
		PlatformConfiguration.getData().ADDL_PBX_BUILD_FILE.push("      " + assetFolderID + " /* assets in Resources */ = {isa = PBXBuildFile; fileRef = " + fileID + " /* assets */; };");
		PlatformConfiguration.getData().ADDL_PBX_FILE_REFERENCE.push("      " + fileID + " /* assets */ = {isa = PBXFileReference; lastKnownFileType = folder; name = assets; path = " + Configuration.getData().APP.FILE + "/assets; sourceTree = \"<group>\"; };");
		PlatformConfiguration.getData().ADDL_PBX_RESOURCE_GROUP.push("            " + fileID + " /* assets */,");			
		PlatformConfiguration.getData().ADDL_PBX_RESOURCES_BUILD_PHASE.push("            " + assetFolderID + " /* assets in Resources */,");
	}

	private function preBuildPerPlatform()
	{
        var libPath : String = DuellLib.getDuellLib("filesystem").getPath();

        var exportPath : String = Path.join([Configuration.getData().OUTPUT,"haxe","filesystem"]);

        var classSourcePath : String = Path.join([libPath,"template","filesystem"]);

        TemplateHelper.recursiveCopyTemplatedFiles(classSourcePath, exportPath, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);

		var targetDirectory = Configuration.getData().OUTPUT + "/" + "ios";
		var projectDirectory = targetDirectory + "/" + Configuration.getData().APP.FILE + "/";
        for (file in fileListToCopy)
        {
        	var targetFolder = Path.join([projectDirectory, "assets", Path.directory(file.relativeFilePath)]);
        	PathHelper.mkdir(targetFolder);
        	FileHelper.copyIfNewer(file.fullPath, Path.join([projectDirectory, "assets", file.relativeFilePath]));
        }
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

	}

	private function postBuildPerPlatform()
	{

	}

	#end
}