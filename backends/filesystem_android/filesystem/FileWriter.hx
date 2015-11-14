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

import types.Data;
import cpp.Lib;

class FileWriter
{
	private var nativeFileHandle : Dynamic;

	public var seekPosition (get, set) : Int;

	private static var filesystem_android_get_seek = Lib.load ("filesystemandroid", "filesystem_android_get_seek", 1);
	public function get_seekPosition () : Int
	{
		return filesystem_android_get_seek(nativeFileHandle);
	}

	private static var filesystem_android_set_seek = Lib.load ("filesystemandroid", "filesystem_android_set_seek", 2);
	public function set_seekPosition (val : Int) : Int
	{
		return filesystem_android_set_seek(nativeFileHandle, val);
	}

	/// the filesystem creates files
	public function new(nativeFileHandle : Dynamic) : Void
	{
		this.nativeFileHandle = nativeFileHandle;
	};

	private static var filesystem_android_file_write = Lib.load ("filesystemandroid", "filesystem_android_file_write", 2);
	public function writeFromData(data : Data)
	{
		filesystem_android_file_write(nativeFileHandle, data.nativeData);
	}

	private static var filesystem_android_file_close = Lib.load ("filesystemandroid", "filesystem_android_file_close", 1);
	public function close()
	{
		filesystem_android_file_close(nativeFileHandle);
		nativeFileHandle = null;
	}
}
