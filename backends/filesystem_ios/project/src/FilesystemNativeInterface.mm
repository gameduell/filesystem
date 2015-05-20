/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <hx/CFFI.h>
#import <Foundation/Foundation.h>

#import <types/NativeData.h>

#import <FileHandle.h>

static NSFileManager *filemanager;

static NSURL* hxstring_to_nsurl(value str)
{
	return [NSURL URLWithString:[NSString stringWithUTF8String:val_string(str)]];
}


/// ======
/// FILESYSTEM
/// ======

/// PATHS
static value filesystem_ios_init() {

	filemanager = [[NSFileManager alloc] init];
	return alloc_null();

}
DEFINE_PRIM (filesystem_ios_init, 0);

/// PATHS
static value filesystem_ios_get_url_to_static_data()
{
	NSString *url = [[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] absoluteString];
	value str = alloc_string([url UTF8String]);
	return str;
}
DEFINE_PRIM (filesystem_ios_get_url_to_static_data, 0);

static value filesystem_ios_get_url_to_cached_data()
{
	NSArray *urls = [filemanager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
	NSString *url = [[urls firstObject] absoluteString];
	value str = alloc_string([url UTF8String]);
	return str;
}
DEFINE_PRIM (filesystem_ios_get_url_to_cached_data, 0);

static value filesystem_ios_get_url_to_temp_data()
{
	NSString *url = [[NSURL fileURLWithPath:NSTemporaryDirectory()] absoluteString];
	value str = alloc_string([url UTF8String]);
	return str;
}
DEFINE_PRIM (filesystem_ios_get_url_to_temp_data, 0);

static value filesystem_ios_create_file(value str)
{
	NSURL* url = hxstring_to_nsurl(str);
	bool success = [filemanager createFileAtPath:[url path] contents:nil attributes:nil];
	return alloc_bool(success);
}
DEFINE_PRIM (filesystem_ios_create_file, 1);

static value filesystem_ios_create_folder(value str)
{
	NSURL* url = hxstring_to_nsurl(str);
	NSError *error = nil;
	bool success = [filemanager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:&error];

	if(error)
	{
		NSLog(@"Error creating folder %@. %@", url, [error localizedDescription]);
	}

	return alloc_bool(success);
}
DEFINE_PRIM (filesystem_ios_create_folder, 1);

static value filesystem_ios_open_file_write(value url)
{
	NSError *error = nil;
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:hxstring_to_nsurl(url) error:&error];

	if(error)
	{
		NSLog(@"Error opening file %@ for write. %@", url, [error localizedDescription]);
	}

	if(!handle)
	{
		return alloc_null();
	}

	value hxFileHandle = FileHandle::createHaxePointer();
	FileHandle* filehandle = ((FileHandle*)val_data(hxFileHandle));
	filehandle->objcFileHandle = [handle retain];

	return hxFileHandle;
}
DEFINE_PRIM (filesystem_ios_open_file_write, 1);

static value filesystem_ios_open_file_read(value str)
{
	NSURL* url = hxstring_to_nsurl(str);
	NSError *error = nil;
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:url error:&error];

	if(error)
	{
		NSLog(@"Error opening file %@ for read. %@", url, [error localizedDescription]);
	}

	if(!handle)
	{
		return alloc_null();
	}

	value hxFileHandle = FileHandle::createHaxePointer();
	FileHandle* filehandle = ((FileHandle*)val_data(hxFileHandle));

	if(!filehandle)
	{
		return alloc_null();
	}

	filehandle->objcFileHandle = [handle retain];

	return hxFileHandle;
}
DEFINE_PRIM (filesystem_ios_open_file_read, 1);

static value filesystem_ios_delete_file(value str)
{
	NSURL* url = hxstring_to_nsurl(str);

	NSError *error = nil;
	bool success = [filemanager removeItemAtURL:url error:&error];

	if(error)
	{
		NSLog(@"Error deleting file %@. %@", url, [error localizedDescription]);
	}

	return alloc_bool(success);
}
DEFINE_PRIM (filesystem_ios_delete_file, 1);

static value filesystem_ios_delete_folder(value str)
{
	NSURL* url = hxstring_to_nsurl(str);

	NSError *error = nil;
	bool success = [filemanager removeItemAtURL:url error:&error];

	if(error)
	{
		NSLog(@"Error deleting folder %@. %@", url, [error localizedDescription]);
	}

	return alloc_bool(success);
}
DEFINE_PRIM (filesystem_ios_delete_folder, 1);

static value filesystem_ios_url_exists(value str)
{
	NSURL* url = hxstring_to_nsurl(str);

	return alloc_bool([filemanager fileExistsAtPath:[url path]]);
}
DEFINE_PRIM (filesystem_ios_url_exists, 1);

static value filesystem_ios_is_folder(value str)
{
	NSURL* url = hxstring_to_nsurl(str);
	BOOL isDirectory = NO;
	BOOL exists = [filemanager fileExistsAtPath:[url path] isDirectory:&isDirectory];

	if(!exists)
		return alloc_bool(NO);
	return alloc_bool(isDirectory);
}
DEFINE_PRIM (filesystem_ios_is_folder, 1);

static value filesystem_ios_is_file(value str)
{
	NSURL* url = hxstring_to_nsurl(str);
	BOOL isDirectory = NO;
	BOOL exists = [filemanager fileExistsAtPath:[url path] isDirectory:&isDirectory];

	if(!exists)
		return alloc_bool(NO);
	return alloc_bool(!isDirectory);
}
DEFINE_PRIM (filesystem_ios_is_file, 1);

/// ======
/// FILEHANDLE
/// ======

static value filesystem_ios_get_seek(value hxFileHandle)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));

	return alloc_int([fileHandle->objcFileHandle offsetInFile]);
}
DEFINE_PRIM (filesystem_ios_get_seek, 1);

static value filesystem_ios_set_seek(value hxFileHandle, value seek)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));
	[fileHandle->objcFileHandle seekToFileOffset:val_int(seek)];

	return alloc_null();
}
DEFINE_PRIM (filesystem_ios_set_seek, 2);

static value filesystem_ios_seek_end_of_file(value hxFileHandle)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));
	[fileHandle->objcFileHandle seekToEndOfFile];

	return alloc_null();
}
DEFINE_PRIM (filesystem_ios_seek_end_of_file, 1);

static value filesystem_ios_file_write(value hxFileHandle, value nativeData)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));
	NativeData* ptr = ((NativeData*)val_data(nativeData));

	[fileHandle->objcFileHandle writeData:[NSData dataWithBytesNoCopy:(ptr->ptr + ptr->offset) length:ptr->offsetLength freeWhenDone:NO]];

	return alloc_null();
}
DEFINE_PRIM (filesystem_ios_file_write, 2);

static value filesystem_ios_file_read(value hxFileHandle, value nativeData)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));
	NativeData* ptr = ((NativeData*)val_data(nativeData));
	FILE *file = fdopen([fileHandle->objcFileHandle fileDescriptor], "r");

	fread(ptr->ptr + ptr->offset, 1, ptr->offsetLength, file);

	return alloc_null();
}
DEFINE_PRIM (filesystem_ios_file_read, 2);

static value filesystem_ios_file_close(value hxFileHandle)
{
	FileHandle* fileHandle = ((FileHandle*)val_data(hxFileHandle));

	fileHandle->close();

	return alloc_null();
}
DEFINE_PRIM (filesystem_ios_file_close, 1);


/// ======
/// OTHER
/// ======
extern "C" void filesystem_ios_main () {

	val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT (filesystem_ios_main);

extern "C" int filesystem_ios_register_prims () { return 0; }
