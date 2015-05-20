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

 import filesystem.FileSystem;

import filesystem.StaticAssetList;

import types.Data;
using types.DataStringTools;

using StringTools;

import Date;

class FileSystemTest extends unittest.TestCase {


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
            "subfolderTestFolder/TestFileSub.txt",
            "TestFile.txt",
            "TestFileBadCharacters +~@.txt"
        ];

        assertTrue(expectedList.length == StaticAssetList.list.length);

        for (i in 0...expectedList.length)
        {
            assertTrue(StaticAssetList.list.indexOf(expectedList[i]) != -1);
        }
    }

    public function testStaticAssetSubfolderList()
    {
        var expectedList = [
            "subfolderTestFolder"
        ];

        assertTrue(expectedList.length == StaticAssetList.folders.length);

        for (i in 0...expectedList.length)
        {
            assertEquals(expectedList[i], StaticAssetList.folders[i]);
        }
    }

    public function testReadFromStatic()
    {
        var testFileURL = FileSystem.instance().urlToStaticData() + "/TestFile.txt";

        var fileRead = FileSystem.instance().getFileReader(testFileURL);
        assertTrue(fileRead != null);

        var fileSize = FileSystem.instance().getFileSize(testFileURL);

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

        FileSystem.instance().deleteFile(testFileURL);
        assertTrue(FileSystem.instance().createFile(testFileURL));

        /// WRITE
        var testFileText = "Test File Text!";
        var inputData : Data = new Data(testFileText.length);
        inputData.writeString(testFileText);
        var fileWrite = FileSystem.instance().getFileWriter(testFileURL);
        fileWrite.writeFromData(inputData);
        fileWrite.close();

        /// READ
        var fileRead = FileSystem.instance().getFileReader(testFileURL);

        var fileSize = FileSystem.instance().getFileSize(testFileURL);
        assertEquals(testFileText.length, fileSize);
        var outputData = new Data(fileSize);

        assertTrue(outputData.readString() != testFileText);

        fileRead.readIntoData(outputData);

        /// COMPARE CONTENT
        assertEquals(testFileText, outputData.readString());

        fileRead.close();

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

    public function testExistenceStaticFolder()
    {
        var testFileURL = FileSystem.instance().urlToStaticData() + "/subfolderTestFolder/TestFileSub.txt";
        assertTrue(FileSystem.instance().urlExists(testFileURL));
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

        var fileSize = FileSystem.instance().getFileSize(testFileURL);

        var fileRead = FileSystem.instance().getFileReader(testFileURL);

        assertTrue(fileRead != null);

        var data = new Data(fileSize);

        var str = "";

        fileRead.readIntoData(data);

        str = data.readString();

        assertEquals(str, "This is a test file!");

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

        var fileSize = FileSystem.instance().getFileSize(testFileURL);

        var outputData = new Data(fileSize);

        assertTrue(outputData.readString() != testFileText);

        assertEquals(outputData.allocedLength, fileSize);
        fileRead.readIntoData(outputData);

        assertEquals(testFileText, outputData.readString());

        fileRead.close();
        fileWrite.close();
    }

    public function testStaticFolderExistence()
    {
        var existentFolder = FileSystem.instance().urlToStaticData() + "/subfolderTestFolder";
        assertTrue(FileSystem.instance().urlExists(existentFolder));
        assertTrue(FileSystem.instance().isFolder(existentFolder));
        assertFalse(FileSystem.instance().isFile(existentFolder));

        var nonExistentFolder = FileSystem.instance().urlToStaticData() + "/nope";
        assertFalse(FileSystem.instance().urlExists(nonExistentFolder));
        assertFalse(FileSystem.instance().isFolder(nonExistentFolder));
        assertFalse(FileSystem.instance().isFile(nonExistentFolder));
    }

    public function testExistenceOfIgnoredFiles()
    {
        var testFileURL = FileSystem.instance().urlToStaticData() + "/TestFile.tobeignored.txt";
        assertTrue(!FileSystem.instance().urlExists(testFileURL));

        testFileURL = FileSystem.instance().urlToStaticData() + "/TestFile2.ToBeIgnored.txt";
        assertTrue(!FileSystem.instance().urlExists(testFileURL));
    }

}
