package duell.build.plugin.library.filesystem.platform;

import duell.helpers.PathHelper;
import duell.helpers.LogHelper;

import sys.FileSystem;
import haxe.io.Path;

class PlatformBuildHelper
{
    public static function removeUnusedFiles(fileListToCopy: Array<String>, targetFolder: String): Void
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
}