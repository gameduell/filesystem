package org.haxe.extension;


import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import java.io.File;
import org.haxe.hxfilesystem.NativeInterface;
import android.util.Log;
import java.lang.Thread;
import java.net.URI;


/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class HxFilesystem extends Extension {
	
	private static final String TAG = "HxFilesystem";
	public static org.haxe.hxjni.HaxeObject haxeAppDelegate;
	public static AssetManager assetManager;

	public static void initialize(org.haxe.hxjni.HaxeObject obj) {

		haxeAppDelegate = obj;

    	NativeInterface.setupNativeAssetManager(Extension.assetManager);
	}

	public static String getCachedDataURL()
	{
    	File filesDir = Extension.mainActivity.getFilesDir();
		return filesDir.toURI().getPath();
	}

	public static String getTempDataURL()
	{
		File tempDir = Extension.mainActivity.getCacheDir();
		return tempDir.toURI().getPath();
	}

	private static void deleteFolder(File fileOrDirectory)
	{
		if (fileOrDirectory.isDirectory())
		    for (File child : fileOrDirectory.listFiles())
		        deleteFolder(child);

		fileOrDirectory.delete();
	}

	public static void deleteFolderRecursively(String path)
	{
		File dir = new File(URI.create("file://" + path));
		deleteFolder(dir);
	}

	
	
	
}