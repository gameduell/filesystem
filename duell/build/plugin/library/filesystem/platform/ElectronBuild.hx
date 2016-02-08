package duell.build.plugin.library.filesystem.platform;

import duell.build.plugin.library.filesystem.AssetProcessorRegister;

import duell.build.plugin.library.filesystem.LibraryConfiguration;
import duell.build.objects.Configuration;

import duell.helpers.LogHelper;
import duell.helpers.PathHelper;
import duell.helpers.FileHelper;

import sys.FileSystem;

import haxe.io.Path;

class ElectronBuild implements IPlatformBuild
{

    private var internalAssetFolder : String;

    public function new( assetFolder:String )
    {
        internalAssetFolder = assetFolder;
    }

    public function postParsePerPlatform(): Void
    {

    }

    public function postPostParsePerPlatform(): Void
    {
        var targetDirectory = Path.join([Configuration.getData().OUTPUT, "electron", internalAssetFolder]);

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
                    LogHelper.info('[FILESYSTEM] Embedding electron asset ' + destPath + "@" + file);
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
            var pathFrom = AssetProcessorRegister.pathToTemporaryAssetArea;
            FileHelper.recursiveCopyFiles(pathFrom, targetDirectory, true, true);
        }
    }

    public function preBuildPerPlatform(): Void
    {

    }

    public function postBuildPerPlatform(): Void
    {

    }
}