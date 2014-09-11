package filesystem;
class StaticAssetList
{
	public static var list = [
		::foreach LIBRARY.FILESYSTEM.STATIC_ASSET_FILENAMES::
		"::__current__::",::end::
	];
}