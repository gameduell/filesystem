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

package org.haxe.duell.filesystem;

import java.io.File;
import java.net.URI;

import org.haxe.duell.DuellActivity;
import org.haxe.duell.Extension;
import org.haxe.duell.filesystem.DuellFileSystemNativeInterface;
import org.haxe.duell.hxjni.HaxeObject;

public class DuellFileSystemActivityExtension extends Extension {

	public static HaxeObject haxeAppDelegate;

	public static void initialize(HaxeObject obj) {

		haxeAppDelegate = obj;

		DuellFileSystemNativeInterface.setupNativeAssetManager(
			DuellActivity.getInstance().getAssets()
		);
	}

	public static String getCachedDataURL() {
		File filesDir = DuellActivity.getInstance().getFilesDir();
		return filesDir.toURI().getPath();
	}

	public static String getTempDataURL() {
		File tempDir = DuellActivity.getInstance().getCacheDir();
		return tempDir.toURI().getPath();
	}

	private static void deleteFolder(File fileOrDirectory) {
		if (fileOrDirectory.isDirectory()) {
			for (File child : fileOrDirectory.listFiles()) {
				deleteFolder(child);
			}
		}

		fileOrDirectory.delete();
	}

	public static void deleteFolderRecursively(String path) {
		File dir = new File(URI.create("file://" + path));
		deleteFolder(dir);
	}


}
