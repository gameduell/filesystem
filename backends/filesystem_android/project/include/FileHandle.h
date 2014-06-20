#include <stdio.h>

#include <hx/CFFI.h>


#include <android/asset_manager.h>


struct FileHandle
{
	AAsset *staticFile;

	FILE *fileHandle;

	static value createHaxePointer(); 

	void close();

	~FileHandle();
};



