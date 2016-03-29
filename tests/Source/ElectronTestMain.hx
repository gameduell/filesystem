package;

import electron.App;
import electron.BrowserWindow;
import js.Node.*;

using StringTools;

class ElectronTestMain
{
    private static var browserWindow : BrowserWindow = null;

    public static function main() : Void 
    {
        App.on(AppEventType.window_all_closed, function()
        {
            App.quit();
        });

        App.on(AppEventType.ready, function()
        {
            browserWindow = new BrowserWindow({width:1024, height:768});
            browserWindow.loadURL('file://' + __dirname + '/index.html');
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