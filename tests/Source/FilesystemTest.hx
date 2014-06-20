import filesystem.Filesystem;

import types.Data;
using types.DataStringTools;

using StringTools;

import Date;

class FilesystemTest extends haxe.unit.TestCase {
    

    public function new ()
    {
        super();
        var staticURL = Filesystem.instance().urlToStaticData();
        var cachedData = Filesystem.instance().urlToCachedData();
        var tempData = Filesystem.instance().urlToTempData();

        trace("FilesystemURLs");
        trace("static url:" + staticURL);
        trace("cached url:" + cachedData);
        trace("temp url:" + tempData);

        #if html5
        trace("asset list: " + Filesystem.instance().getFileList(staticURL));
        #end
    }
    
    public function testURLs()
    {
        var staticURL = Filesystem.instance().urlToStaticData();
        var cachedData = Filesystem.instance().urlToCachedData();
        var tempData = Filesystem.instance().urlToTempData();

        assertTrue(staticURL != null && staticURL != "");
        assertTrue(cachedData != null && cachedData != "");
        assertTrue(tempData != null && tempData != "");
    }

    private var testCacheFolder : String;
    private var testTempFolder : String;

    public function testCreation()
    {
        var testFolder = ("/testFolder " + Date.now().getTime()).urlEncode();
        testCacheFolder = Filesystem.instance().urlToCachedData() + testFolder;
        testTempFolder = Filesystem.instance().urlToTempData() + testFolder;
        assertTrue(Filesystem.instance().createFolder(testCacheFolder));
        assertTrue(Filesystem.instance().createFolder(testTempFolder));

        /// CACHED
        var urlCachedFile = testCacheFolder + "/test.txt";
        Filesystem.instance().createFile(urlCachedFile);
        var fileWrite = Filesystem.instance().getFileWriter(urlCachedFile);
        assertTrue(fileWrite != null);

        var fileRead = Filesystem.instance().getFileReader(urlCachedFile);
        assertTrue(fileRead != null);

        /// TEMP
        var urlTempFile = testTempFolder + "/test.txt";
        Filesystem.instance().createFile(urlTempFile);
        var fileWrite = Filesystem.instance().getFileWriter(urlTempFile);
        assertTrue(fileWrite != null);

        var fileRead = Filesystem.instance().getFileReader(urlTempFile);
        assertTrue(fileRead != null);


        fileRead.close();
        fileWrite.close();
    }
    
    public function testReadFromStatic()
    {
        var testFileURL = Filesystem.instance().urlToStaticData() + "/TestFile.txt";

        var fileRead = Filesystem.instance().getFileReader(testFileURL);

        
        assertTrue(fileRead != null);
        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;
        fileRead.seekPosition = prevSeek;

        var data = new Data(fileSize);

        var str = data.createStringFromData();

        assertTrue(str != "This is a test file!");

        fileRead.readIntoData(data);


        str = data.createStringFromData();

        assertEquals("This is a test file!", str);

        fileRead.close();
    }
    

    public function testWrite()
    {
        var testFileURL = testCacheFolder + "/TestFile.txt";

        Filesystem.instance().createFile(testFileURL);

        /// WRITE
        var testFileText = "Test File Text!";
        var inputData : Data = new Data(testFileText.length);
        inputData.setString(testFileText);
        var fileWrite = Filesystem.instance().getFileWriter(testFileURL);
        fileWrite.writeFromData(inputData);

        /// READ
        var fileRead = Filesystem.instance().getFileReader(testFileURL);

        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;

        fileRead.seekPosition = prevSeek;

        var outputData = new Data(fileSize);

        assertTrue(outputData.createStringFromData() != testFileText);

        fileRead.readIntoData(outputData);

        /// COMPARE CONTENT
        assertEquals(testFileText, outputData.createStringFromData());

        fileRead.close();
        fileWrite.close();
    }


    public function testExistence()
    {
        var testFolderForCheckingExistence = testCacheFolder + "/testFolderForCheckingExistence";
        var testFileURL = testFolderForCheckingExistence + "/TestFileForExistence.txt";

        /// FOLDER
        assertTrue(!Filesystem.instance().isFolder(testFolderForCheckingExistence));
        assertTrue(!Filesystem.instance().urlExists(testFolderForCheckingExistence));
        assertTrue(!Filesystem.instance().isFile(testFolderForCheckingExistence));

        assertTrue(Filesystem.instance().createFolder(testFolderForCheckingExistence));

        assertTrue(Filesystem.instance().urlExists(testFolderForCheckingExistence));
        assertTrue(Filesystem.instance().isFolder(testFolderForCheckingExistence));
        assertTrue(!Filesystem.instance().isFile(testFolderForCheckingExistence));

        /// FILE
        assertTrue(!Filesystem.instance().isFolder(testFileURL));
        assertTrue(!Filesystem.instance().urlExists(testFileURL));
        assertTrue(!Filesystem.instance().isFile(testFileURL));

        Filesystem.instance().createFile(testFileURL);

        assertTrue(!Filesystem.instance().isFolder(testFileURL));
        assertTrue(Filesystem.instance().urlExists(testFileURL));
        assertTrue(Filesystem.instance().isFile(testFileURL));
    }

    public function testDelete()
    {
        var testFolderForDeletion = testCacheFolder + "/testFolderForDeletion";
        assertTrue(Filesystem.instance().createFolder(testFolderForDeletion));

        var testFileURLForDeletion1 = testFolderForDeletion + "/TestFileForDeletion1.txt";
        Filesystem.instance().createFile(testFileURLForDeletion1);
        var testFileURLForDeletion2 = testFolderForDeletion + "/TestFileForDeletion2.txt";
        Filesystem.instance().createFile(testFileURLForDeletion2);

        /// SINGLE FILE
        assertTrue(Filesystem.instance().urlExists(testFileURLForDeletion1));
        Filesystem.instance().deleteFile(testFileURLForDeletion1);
        assertTrue(!Filesystem.instance().urlExists(testFileURLForDeletion1));

        /// FILE IN FOLDER AND FOLDER
        assertTrue(Filesystem.instance().urlExists(testFileURLForDeletion2));
        assertTrue(Filesystem.instance().urlExists(testFolderForDeletion));
        Filesystem.instance().deleteFolder(testFolderForDeletion);
        assertTrue(!Filesystem.instance().urlExists(testFileURLForDeletion2));
        assertTrue(!Filesystem.instance().urlExists(testFolderForDeletion));
    }


    public function testReadWeirdCharacterFileFromStatic()
    {
        var testFileURL = Filesystem.instance().urlToStaticData() + "/" + "TestFileBadCharacters +~@.txt".urlEncode();

        var fileRead = Filesystem.instance().getFileReader(testFileURL);
        
        assertTrue(fileRead != null);
        
        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;
        fileRead.seekPosition = prevSeek;

        var data = new Data(fileSize);

        var str = data.createStringFromData();

        assertTrue(str != "This is a test file!");

        fileRead.readIntoData(data);

        str = data.createStringFromData();

        assertTrue(str == "This is a test file!");

        fileRead.close();
    }

    
    public function testWriteWeirdCharacterFile()
    {
        var testFileURL = testCacheFolder + "/TestFileBadCharacters +~@.txt".urlEncode();

        Filesystem.instance().createFile(testFileURL);

        var testFileText = "Test File Text!";
        var inputData : Data = new Data(testFileText.length);
        inputData.setString(testFileText);

        var fileWrite = Filesystem.instance().getFileWriter(testFileURL);
        fileWrite.writeFromData(inputData);

        var fileRead = Filesystem.instance().getFileReader(testFileURL);

        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;

        fileRead.seekPosition = prevSeek;

        var outputData = new Data(fileSize);

        assertTrue(outputData.createStringFromData() != testFileText);

        assertEquals(outputData.allocedLength, fileSize);
        fileRead.readIntoData(outputData);

        assertEquals(testFileText, outputData.createStringFromData());

        fileRead.close();
        fileWrite.close();
    }
    
}