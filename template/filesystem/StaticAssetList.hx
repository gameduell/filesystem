package filesystem;
class StaticAssetList
{
	private static var list = [
		::foreach LIBRARY.FILESYSTEM.STATIC_ASSET_FILENAMES::
		::__current__::,::end::
	];
}