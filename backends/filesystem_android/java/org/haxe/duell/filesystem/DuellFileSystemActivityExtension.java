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