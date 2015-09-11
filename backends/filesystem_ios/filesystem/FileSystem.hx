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

class FileSystem
{
	private var filesystem_ios_init = Lib.load ("filesystems_ios", "filesystem_ios_init", 0);
	private var filesystem_ios_get_url_to_static_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_static_data", 0);
	private var filesystem_ios_get_url_to_cached_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_cached_data", 0);
	private var filesystem_ios_get_url_to_temp_data = Lib.load ("filesystem_ios", "filesystem_ios_get_url_to_temp_data", 0);
	private function new() : Void
	{
		filesystem_ios_init();
		staticDataURL = filesystem_ios_get_url_to_static_data() + "/assets/";
		cachedDataURL = filesystem_ios_get_url_to_cached_data();
		tempDataURL = filesystem_ios_get_url_to_temp_data();
	}

	/// NATIVE ACCESS

	private var staticDataURL : String;
	public function getUrlToStaticData() : String
	{
		return staticDataURL;
	}
	@:deprecated("urlToStaticData is deprecated. Use FileSystem.getUrlToStaticData() instead!")
	public function urlToStaticData() : String
	{
		return staticDataURL;
	}

	private var cachedDataURL : String;
	public function getUrlToCachedData() : String
	{
		return cachedDataURL;
	}
	@:deprecated("urlToCachedData is deprecated. Use FileSystem.getUrlToCachedData() instead!")
	public function urlToCachedData() : String
	{
		return cachedDataURL;
	}

	private var tempDataURL : String;
	public function getUrlToTempData() : String
	{
		return tempDataURL;
	}
	@:deprecated("urlToTempData is deprecated. Use FileSystem.getUrlToTempData() instead!")
	public function urlToTempData() : String
	{
		return tempDataURL;
	}

	private var filesystem_ios_create_file = Lib.load ("filesystem_ios", "filesystem_ios_create_file", 1);
	public function createFile(url : String) : Bool
	{
		return filesystem_ios_create_file(url);
	}

	private var filesystem_ios_open_file_write = Lib.load ("filesystem_ios", "filesystem_ios_open_file_write", 1);
	public function getFileWriter(url : String) : FileWriter
	{
		var nativeHandle = filesystem_ios_open_file_write(url);

		if(nativeHandle == null)
			return null;

		var file = new FileWriter(nativeHandle);
		return file;
	}

	private var filesystem_ios_open_file_read = Lib.load ("filesystem_ios", "filesystem_ios_open_file_read", 1);
	public function getFileReader(url : String) : FileReader
	{
		var nativeHandle = filesystem_ios_open_file_read(url);

		if(nativeHandle == null)
			return null;

		var file = new FileReader(nativeHandle);
		return file;
	}

	private var filesystem_ios_create_folder = Lib.load ("filesystem_ios", "filesystem_ios_create_folder", 1);
	public function createFolder(url : String) : Bool
	{
		return filesystem_ios_create_folder(url);
	}

	private var filesystem_ios_delete_file = Lib.load ("filesystem_ios", "filesystem_ios_delete_file", 1);
	public function deleteFile(url : String) : Void
	{
		return filesystem_ios_delete_file(url);
	}

	private var filesystem_ios_delete_folder = Lib.load ("filesystem_ios", "filesystem_ios_delete_folder", 1);
	public function deleteFolder(url : String) : Void
	{
		return filesystem_ios_delete_folder(url);
	}

	private var filesystem_ios_url_exists = Lib.load ("filesystem_ios", "filesystem_ios_url_exists", 1);
	public function urlExists(url : String) : Bool
	{
		return filesystem_ios_url_exists(url);
	}

	private var filesystem_ios_is_folder = Lib.load ("filesystem_ios", "filesystem_ios_is_folder", 1);
	public function isFolder(url : String) : Bool
	{
		return filesystem_ios_is_folder(url);
	}

	private var filesystem_ios_is_file = Lib.load ("filesystem_ios", "filesystem_ios_is_file", 1);
	public function isFile(url : String) : Bool
	{
		return filesystem_ios_is_file(url);
	}

	private var filesystem_ios_seek_end_of_file = Lib.load ("filesystem_ios", "filesystem_ios_seek_end_of_file", 1);
	private var filesystem_ios_get_seek = Lib.load ("filesystem_ios", "filesystem_ios_get_seek", 1);
	private var filesystem_ios_file_close = Lib.load ("filesystem_ios", "filesystem_ios_file_close", 1);
	public function getFileSize(url : String) : Int
	{
		var nativeHandle = filesystem_ios_open_file_read(url);
		if(nativeHandle == null)
			return 0;

		filesystem_ios_seek_end_of_file(nativeHandle);
		var newSeek = filesystem_ios_get_seek(nativeHandle);
		filesystem_ios_file_close(nativeHandle);

		return newSeek;
	}

	/// SINGLETON
	static var fileSystemInstance : FileSystem;
	static public inline function instance() : FileSystem
	{
		return fileSystemInstance;
	}
	public static function initialize(finishedCallback : Void->Void) : Void
	{
		if(fileSystemInstance == null)
		{
			fileSystemInstance = new FileSystem();
		}

		finishedCallback();
	}
}
