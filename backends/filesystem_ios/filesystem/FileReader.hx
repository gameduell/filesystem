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

class FileReader
{
	private var nativeFileHandle : Dynamic;

	public var seekPosition (get, set) : Int;

	private var filesystem_ios_get_seek = Lib.load ("filesystem_ios", "filesystem_ios_get_seek", 1);
	public function get_seekPosition () : Int
	{
		return filesystem_ios_get_seek(nativeFileHandle);
	}

	private var filesystem_ios_set_seek = Lib.load ("filesystem_ios", "filesystem_ios_set_seek", 2);
	public function set_seekPosition (val : Int) : Int
	{
		return filesystem_ios_set_seek(nativeFileHandle, val);
	}

	/// the filesystem creates files
	public function new(nativeFileHandle : Dynamic) : Void
	{
		this.nativeFileHandle = nativeFileHandle;
	};

	private var filesystem_ios_file_read = Lib.load ("filesystem_ios", "filesystem_ios_file_read", 2);
	public function readIntoData(data : Data)
	{
		filesystem_ios_file_read(nativeFileHandle, data.nativeData);
	}

	private var filesystem_ios_file_close = Lib.load ("filesystem_ios", "filesystem_ios_file_close", 1);
	public function close()
	{
		filesystem_ios_file_close(nativeFileHandle);
		nativeFileHandle = null;
	}
}
