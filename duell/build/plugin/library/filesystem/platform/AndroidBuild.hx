package duell.build.plugin.library.filesystem.platform;

import duell.build.plugin.library.filesystem.AssetProcessorRegister;

import duell.build.plugin.platform.PlatformConfiguration;
import duell.build.objects.Configuration;

import duell.helpers.PathHelper;
import duell.helpers.FileHelper;

import haxe.io.Path;

class AndroidBuild implements IPlatformBuild
{

    public function new()
    {

    }

    public function postParsePerPlatform(): Void
    {

    }

    public function postPostParsePerPlatform(): Void
    {

    }

    public function preBuildPerPlatform(): Void
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

        PlatformBuildHelper.removeUnusedFiles( fileListToCopy, targetDirectory );
    }

    public function postBuildPerPlatform(): Void
    {

    }
}