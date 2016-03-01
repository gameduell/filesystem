package duell.build.plugin.library.filesystem.platform;

import duell.helpers.LogHelper;

class NoSupportedPlatform implements IPlatformBuild
{
    public function new(){}

    public function postParsePerPlatform(): Void {}

    public function postPostParsePerPlatform(): Void {}

    public function preBuildPerPlatform(): Void {}

    public function postBuildPerPlatform(): Void {}
}