package;

import electron.App;
import electron.BrowserWindow;
import electron.CrashReporter;
import js.Node.*;

using StringTools;

class ElectronTestMain
{
    private static var browserWindow : BrowserWindow = null;

    public static function main() : Void 
    {
        CrashReporter.start();

        App.on(AppEvent.WINDOW_ALL_CLOSED, function()
        {
            App.quit();
        });

        App.on(AppEvent.READY, function()
        {
            browserWindow = new BrowserWindow({width:1024, height:768});
            browserWindow.loadUrl('file://' + __dirname + '/index.html');
            browserWindow.webContents.openDevTools();

            browserWindow.on('closed', function()
            {
                browserWindow = null;
            });

            process.stdin.setEncoding('utf8');
            process.stdin.on('data', function( chunk:String )
            {
                trace("ElectronTestMain :: stdin :: data : '" + chunk + "'");
                if(chunk != null)
                {
                    switch( chunk.trim() )
                    {
                        case "exit": 
                             App.quit();
                    }
                }
            });
        });
    }
}