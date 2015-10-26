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

package filesystem;

import cpp.Lib;

import hxjni.JNI;

using StringTools;

class FileSystem
{

	private static var filesystem_android_init = Lib.load("filesystemandroid", "filesystem_android_init", 0);

	private static var j_initialize = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "initialize", "(Lorg/haxe/duell/hxjni/HaxeObject;)V");
	private static var j_getCachedDataURL = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "getCachedDataURL", "()Ljava/lang/String;");
	private static var j_getTempDataURL = JNI.createStaticMethod("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "getTempDataURL", "()Ljava/lang/String;");
	private function new() : Void
	{
		filesystem_android_init();
		j_initialize(this);

		staticDataURL = "assets:/";
		cachedDataURL = j_getCachedDataURL();
		tempDataURL = j_getTempDataURL();
	}

	/// NATIVE ACCESS

	private var staticDataURL : String;
	public function getUrlToStaticData() : String
	{
		return staticDataURL;
	}

	private var cachedDataURL : String;
	public function getUrlToCachedData() : String
	{
		return cachedDataURL;
	}

	private var tempDataURL : String;
	public function getUrlToTempData() : String
	{
		return tempDataURL;
	}

	private static var filesystem_android_create_file = Lib.load ("filesystemandroid", "filesystem_android_create_file", 1);
	public function createFile(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_create_file(path);
	}

	private static var filesystem_android_open_file_write = Lib.load ("filesystemandroid", "filesystem_android_open_file_write", 1);
	public function getFileWriter(url : String) : FileWriter
	{
		var path = url.urlDecode();
		var nativeHandle = filesystem_android_open_file_write(path);

		if(nativeHandle == null)
			return null;

		var file = new FileWriter(nativeHandle);
		return file;
	}

	private static var filesystem_android_open_file_read = Lib.load ("filesystemandroid", "filesystem_android_open_file_read", 1);
	public function getFileReader(url : String) : FileReader
	{
		var path = url.urlDecode();
		var nativeHandle = filesystem_android_open_file_read(path);

		if(nativeHandle == null)
			return null;

		var file = new FileReader(nativeHandle);
		return file;
	}

	private static var filesystem_android_create_folder = Lib.load ("filesystemandroid", "filesystem_android_create_folder", 1);
	public function createFolder(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_create_folder(path);
	}

	private static var filesystem_android_delete_file = Lib.load ("filesystemandroid", "filesystem_android_delete_file", 1);
	public function deleteFile(url : String) : Void
	{
		var path = url.urlDecode();
		return filesystem_android_delete_file(path);
	}

	private static var j_deleteFolderRecursively = JNI.createStaticMethod ("org/haxe/duell/filesystem/DuellFileSystemActivityExtension", "deleteFolderRecursively", "(Ljava/lang/String;)V");
	public function deleteFolder(url : String) : Void
	{
		/// there is no easy way to this in c
		return j_deleteFolderRecursively(url);
	}

	private static var filesystem_android_url_exists = Lib.load ("filesystemandroid", "filesystem_android_url_exists", 1);
	public function urlExists(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_url_exists(path);
	}

	private static var filesystem_android_is_folder = Lib.load ("filesystemandroid", "filesystem_android_is_folder", 1);
	public function isFolder(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_is_folder(path);
	}

	private static var filesystem_android_is_file = Lib.load ("filesystemandroid", "filesystem_android_is_file", 1);
	public function isFile(url : String) : Bool
	{
		var path = url.urlDecode();
		return filesystem_android_is_file(path);
	}

	private static var filesystem_android_seek_end_of_file = Lib.load ("filesystemandroid", "filesystem_android_seek_end_of_file", 1);
	private static var filesystem_android_get_seek = Lib.load ("filesystemandroid", "filesystem_android_get_seek", 1);
	private static var filesystem_android_file_close = Lib.load ("filesystemandroid", "filesystem_android_file_close", 1);
	public function getFileSize(url : String) : Int
	{
		var path = url.urlDecode();
		var nativeHandle = filesystem_android_open_file_read(path);
		if(nativeHandle == null)
			return 0;

		var prevSeek = filesystem_android_get_seek(nativeHandle);
		filesystem_android_seek_end_of_file(nativeHandle);
		var newSeek = filesystem_android_get_seek(nativeHandle);
		filesystem_android_file_close(nativeHandle);

		return newSeek - prevSeek;
	}

	/// SINGLETON
    static var fileSystemInstance : FileSystem;
    static public inline function instance() : FileSystem
    {
        return fileSystemInstance;
    }

    public static function initialize(finishedCallback : Void -> Void):Void
    {
        if(fileSystemInstance == null)
        {
            fileSystemInstance = new FileSystem();
        }

        finishedCallback();
    }
}
