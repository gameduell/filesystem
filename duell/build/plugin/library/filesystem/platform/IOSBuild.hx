package duell.build.plugin.library.filesystem.platform;

import duell.build.plugin.library.filesystem.AssetProcessorRegister;

import duell.build.plugin.platform.PlatformConfiguration;
import duell.build.objects.Configuration;

import duell.helpers.PathHelper;
import duell.helpers.FileHelper;

import sys.FileSystem;
import haxe.io.Path;

class IOSBuild implements IPlatformBuild
{
    private var assetFolder : String;

    public function new( assetFolder:String )
    {
        this.assetFolder = assetFolder;
    }

    public function postParsePerPlatform(): Void
    {
        /// ADD ASSET FOLDER TO THE XCODE
        var assetFolderID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
        var fileID = duell.build.helpers.XCodeHelper.getUniqueIDForXCode();
        PlatformConfiguration.getData().ADDL_PBX_BUILD_FILE.push('      ' + assetFolderID + ' /* $assetFolder in Resources */ = {isa = PBXBuildFile; fileRef = ' + fileID + ' /* $assetFolder */; };');
        PlatformConfiguration.getData().ADDL_PBX_FILE_REFERENCE.push('      ' + fileID + ' /* $assetFolder */ = {isa = PBXFileReference; lastKnownFileType = folder; name = $assetFolder; path = ' + Configuration.getData().APP.FILE + '/$assetFolder; sourceTree = \"<group>\"; };');
        PlatformConfiguration.getData().ADDL_PBX_RESOURCE_GROUP.push('            ' + fileID + ' /* $assetFolder */,');
        PlatformConfiguration.getData().ADDL_PBX_RESOURCES_BUILD_PHASE.push('            ' + assetFolderID + ' /* $assetFolder in Resources */,');
    }

    public function postPostParsePerPlatform(): Void
    {

    }

    public function preBuildPerPlatform(): Void
    {
        var targetFolder = Path.join([  Configuration.getData().OUTPUT,
                                        "ios",
                                        Configuration.getData().APP.FILE,
                                        assetFolder]);

        if (FileSystem.exists(targetFolder))
        {
            PathHelper.removeDirectory(targetFolder);
        }

        PathHelper.mkdir(targetFolder);
        FileHelper.recursiveCopyFiles(AssetProcessorRegister.pathToTemporaryAssetArea, targetFolder, true, true);
    }

    public function postBuildPerPlatform(): Void
    {

    }
}