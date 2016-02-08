package duell.build.plugin.library.filesystem.platform;

import duell.helpers.LogHelper;

class NoSupportedPlatform implements IPlatformBuild
{
    public function new(){}

    public function postParsePerPlatform(): Void
    {
        LogHelper.info('No supported platform!');
    }

    public function postPostParsePerPlatform(): Void
    {
        LogHelper.info('No supported platform!');
    }

    public function preBuildPerPlatform(): Void
    {
        LogHelper.info('No supported platform!');
    }

    public function postBuildPerPlatform(): Void
    {
        LogHelper.info('No supported platform!');
    }
}