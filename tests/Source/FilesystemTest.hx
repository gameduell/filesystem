import filesystem.FileSystem;

import filesystem.StaticAssetList;

import types.Data;
using types.DataStringTools;

using StringTools;

import Date;

class FileSystemTest extends haxe.unit.TestCase {
    

    public function new ()
    {
        super();

        var staticURL = FileSystem.instance().urlToStaticData();
        var cachedData = FileSystem.instance().urlToCachedData();
        var tempData = FileSystem.instance().urlToTempData();

        var testFolder = ("/testFolder " + Date.now().getTime()).urlEncode();
        testCacheFolder = FileSystem.instance().urlToCachedData() + testFolder;
        testTempFolder = FileSystem.instance().urlToTempData() + testFolder;

        FileSystem.instance().createFolder(testCacheFolder);
        FileSystem.instance().createFolder(testTempFolder);
    }
    
    public function testURLs()
    {
        var staticURL = FileSystem.instance().urlToStaticData();
        var cachedData = FileSystem.instance().urlToCachedData();
        var tempData = FileSystem.instance().urlToTempData();

        assertTrue(staticURL != null && staticURL != "");
        assertTrue(cachedData != null && cachedData != "");
        assertTrue(tempData != null && tempData != "");
    }

    private var testCacheFolder : String;
    private var testTempFolder : String;

    public function testCreation()
    {

        /// CACHED
        var urlCachedFile = testCacheFolder + "/test.txt";
        FileSystem.instance().createFile(urlCachedFile);
        var fileWrite = FileSystem.instance().getFileWriter(urlCachedFile);
        assertTrue(fileWrite != null);

        var fileRead = FileSystem.instance().getFileReader(urlCachedFile);
        assertTrue(fileRead != null);

        /// TEMP
        var urlTempFile = testTempFolder + "/test.txt";
        FileSystem.instance().createFile(urlTempFile);
        var fileWrite = FileSystem.instance().getFileWriter(urlTempFile);
        assertTrue(fileWrite != null);

        var fileRead = FileSystem.instance().getFileReader(urlTempFile);
        assertTrue(fileRead != null);


        fileRead.close();
        fileWrite.close();
    }

    public function testStaticAssetList()
    {
        var expectedList = [
        
            "lime.png",
            "lime.svg",
            "TestFile.txt",
            "TestFileBadCharacters +~@.txt",
        ];

        assertTrue(expectedList.length == StaticAssetList.list.length);

        for (i in 0...expectedList.length)
        {
            assertEquals(expectedList[i], StaticAssetList.list[i]);
        }
    }
    
    public function testReadFromStatic()
    {
        var testFileURL = FileSystem.instance().urlToStaticData() + "/TestFile.txt";

        var fileRead = FileSystem.instance().getFileReader(testFileURL);

        
        assertTrue(fileRead != null);
        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;
        fileRead.seekPosition = prevSeek;

        var data = new Data(fileSize);

        var str = data.readString();

        assertTrue(str != "This is a test file!");

        fileRead.readIntoData(data);


        str = data.readString();

        assertEquals("This is a test file!", str);

        fileRead.close();
    }
    

    public function testWrite()
    {
        var testFileURL = testCacheFolder + "/TestFile.txt";

        FileSystem.instance().createFile(testFileURL);

        /// WRITE
        var testFileText = "Test File Text!";
        var inputData : Data = new Data(testFileText.length);
        inputData.writeString(testFileText);
        var fileWrite = FileSystem.instance().getFileWriter(testFileURL);
        fileWrite.writeFromData(inputData);

        /// READ
        var fileRead = FileSystem.instance().getFileReader(testFileURL);

        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;

        fileRead.seekPosition = prevSeek;

        var outputData = new Data(fileSize);

        assertTrue(outputData.readString() != testFileText);

        fileRead.readIntoData(outputData);

        /// COMPARE CONTENT
        assertEquals(testFileText, outputData.readString());

        fileRead.close();
        fileWrite.close();
    }


    public function testExistence()
    {
        var testFolderForCheckingExistence = testCacheFolder + "/testFolderForCheckingExistence";
        var testFileURL = testFolderForCheckingExistence + "/TestFileForExistence.txt";

        /// FOLDER
        assertTrue(!FileSystem.instance().isFolder(testFolderForCheckingExistence));
        assertTrue(!FileSystem.instance().urlExists(testFolderForCheckingExistence));
        assertTrue(!FileSystem.instance().isFile(testFolderForCheckingExistence));

        assertTrue(FileSystem.instance().createFolder(testFolderForCheckingExistence));

        assertTrue(FileSystem.instance().urlExists(testFolderForCheckingExistence));
        assertTrue(FileSystem.instance().isFolder(testFolderForCheckingExistence));
        assertTrue(!FileSystem.instance().isFile(testFolderForCheckingExistence));

        /// FILE
        assertTrue(!FileSystem.instance().isFolder(testFileURL));
        assertTrue(!FileSystem.instance().urlExists(testFileURL));
        assertTrue(!FileSystem.instance().isFile(testFileURL));

        FileSystem.instance().createFile(testFileURL);

        assertTrue(!FileSystem.instance().isFolder(testFileURL));
        assertTrue(FileSystem.instance().urlExists(testFileURL));
        assertTrue(FileSystem.instance().isFile(testFileURL));
    }

    public function testDelete()
    {
        var testFolderForDeletion = testCacheFolder + "/testFolderForDeletion";
        assertTrue(FileSystem.instance().createFolder(testFolderForDeletion));

        var testFileURLForDeletion1 = testFolderForDeletion + "/TestFileForDeletion1.txt";
        FileSystem.instance().createFile(testFileURLForDeletion1);
        var testFileURLForDeletion2 = testFolderForDeletion + "/TestFileForDeletion2.txt";
        FileSystem.instance().createFile(testFileURLForDeletion2);

        /// SINGLE FILE
        assertTrue(FileSystem.instance().urlExists(testFileURLForDeletion1));
        FileSystem.instance().deleteFile(testFileURLForDeletion1);
        assertTrue(!FileSystem.instance().urlExists(testFileURLForDeletion1));

        /// FILE IN FOLDER AND FOLDER
        assertTrue(FileSystem.instance().urlExists(testFileURLForDeletion2));
        assertTrue(FileSystem.instance().urlExists(testFolderForDeletion));
        FileSystem.instance().deleteFolder(testFolderForDeletion);
        assertTrue(!FileSystem.instance().urlExists(testFileURLForDeletion2));
        assertTrue(!FileSystem.instance().urlExists(testFolderForDeletion));
    }


    public function testReadWeirdCharacterFileFromStatic()
    {
        var testFileURL = FileSystem.instance().urlToStaticData() + "/" + "TestFileBadCharacters +~@.txt".urlEncode();

        var fileRead = FileSystem.instance().getFileReader(testFileURL);
        
        assertTrue(fileRead != null);
        
        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;
        fileRead.seekPosition = prevSeek;

        var data = new Data(fileSize);

        var str = data.readString();

        assertTrue(str != "This is a test file!");

        fileRead.readIntoData(data);

        str = data.readString();

        assertTrue(str == "This is a test file!");

        fileRead.close();
    }

    
    public function testWriteWeirdCharacterFile()
    {
        var testFileURL = testCacheFolder + "/TestFileBadCharacters +~@.txt".urlEncode();

        FileSystem.instance().createFile(testFileURL);

        var testFileText = "Test File Text!";
        var inputData : Data = new Data(testFileText.length);
        inputData.writeString(testFileText);

        var fileWrite = FileSystem.instance().getFileWriter(testFileURL);
        fileWrite.writeFromData(inputData);

        var fileRead = FileSystem.instance().getFileReader(testFileURL);

        var prevSeek = fileRead.seekPosition;
        fileRead.seekEndOfFile();
        var endSeek = fileRead.seekPosition;
        var fileSize = endSeek - prevSeek;

        fileRead.seekPosition = prevSeek;

        var outputData = new Data(fileSize);

        assertTrue(outputData.readString() != testFileText);

        assertEquals(outputData.allocedLength, fileSize);
        fileRead.readIntoData(outputData);

        assertEquals(testFileText, outputData.readString());

        fileRead.close();
        fileWrite.close();
    }
    
}