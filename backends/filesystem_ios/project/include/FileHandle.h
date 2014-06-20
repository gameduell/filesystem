#ifndef __TYPES_FILE_HANDLE_
#define __TYPES_FILE_HANDLE_


#import <Foundation/Foundation.h>
#import <hx/CFFI.h>

class FileHandle
{
	public:
		NSFileHandle *objcFileHandle;

		void close();
		static value createHaxePointer();

		~FileHandle();
};

#endif //__TYPES_FILE_HANDLE_
