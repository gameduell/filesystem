package duell.build.plugin.library.filesystem.platform;

interface IPlatformBuild
{
    function postParsePerPlatform(): Void;
    function postPostParsePerPlatform(): Void;
    function preBuildPerPlatform(): Void;
    function postBuildPerPlatform(): Void;
}