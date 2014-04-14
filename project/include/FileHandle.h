#import <Foundation/Foundation.h>
#import <hx/CFFI.h>

struct FileHandle
{
	NSFileHandle *objcFileHandle;
	static value createHaxePointer();

	~FileHandle();


};



