#import <FileHandle.h>


DEFINE_KIND(k_FileHandle);
value FileHandle::createHaxePointer()
{
	value v;
	v = alloc_abstract(k_FileHandle, malloc(sizeof(FileHandle)));
	return v;
}


FileHandle::~FileHandle()
{
	[objcFileHandle release];
	printf("Released Objc File Handle!\\n"); 
}

