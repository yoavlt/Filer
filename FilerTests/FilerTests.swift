//
//  FilerTests.swift
//  FilerTests
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import UIKit
import XCTest
import Filer

class FilerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testCreateDeleteDirectory() {
        XCTAssert(Filer.mkdir(.Document, dirName: "hoge"), "create directory successfuly")
        XCTAssert(Filer.exists(.Document, path: "hoge"), "exists diretory")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"), "delete directory successfuly")
        XCTAssertFalse(Filer.exists(.Document, path: "hoge"), "didn't exists diretory")
    }
    
    func testReadWriteFile() {
        let file = File(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssertEqual(FileReader(file: file).read(), "test!!", "write body correctly")
        XCTAssert(file.delete(), "delete file")
        XCTAssertFalse(file.isExists, "test delete file")
    }

    func testTouchCommand() {
        XCTAssert(Filer.touch(.Document, path: "test.txt"), "touch file")
        let file = File(fileName: "test.txt")
        XCTAssert(file.delete(), "delete file")
        XCTAssertFalse(file.isExists, "test delete file")
    }

    func testCopyFile() {
        Filer.rm(.Document, path: "test2.txt")
        let file = File(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssert(Filer.cp(.Document, srcPath: "test.txt", toPath: "test2.txt"), "copy file successfuly")
        XCTAssert(Filer.exists(.Document, path: "test.txt"), "test dupliated")
        XCTAssert(Filer.exists(.Document, path: "test2.txt"), "test dupliated")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete file")
        XCTAssert(Filer.rm(.Document, path: "test2.txt"), "delete file")
    }

    func testMoveFile() {
        let file = File(directory: .Document, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(Filer.mv(.Document, srcPath: "test.txt", toPath: "test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(File(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.Document, path: "test4.txt"), "delete file")
    }
    
    func testMoveMethodFile() {
        let file = File(directory: .Document, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(file.moveTo("test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(File(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.Document, path: "test4.txt"), "delete file")
    }

    func testCopyMethods() {
        let file = File(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssert(file.copyTo("test2.txt"), "copy file successfuly")
        XCTAssert(Filer.exists(.Document, path: "test.txt"), "test dupliated")
        XCTAssert(Filer.exists(.Document, path: "test2.txt"), "test dupliated")
        XCTAssert(file.delete(), "delete successfuly")
        XCTAssert(Filer.rm(.Document, path: "test2.txt"), "delete file")
    }
    
    func contains <T : Equatable> (coll: [T], value: T) -> Bool {
        for item in coll {
            if item == value {
                return true
            }
        }
        return false
    }
    
    func testLs() {
        let sampleFileNames = ["test.txt", "test2.txt", "test3.txt"]
        let sampleFiles = sampleFileNames.map { File(fileName: $0) }
        for file in sampleFiles {
            FileWriter(file: file).write("test!!")
        }
        let files = Filer.ls(.Document, dir: "")!
        for file in files {
            XCTAssert(contains(sampleFiles, value: file), "filename matches")
            Filer.rm(StoreDirectory.Document, path: file.fileName)
        }
    }

    func testDu() {
        let file = File(fileName: "test.txt")
        "test!" --> file
        XCTAssert(Filer.du(.Document, path: file.relativePath) > 0, "file size greater than zero")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete png file")
    }

    func testExt() {
        let sampleFileNames = ["test.txt", "test.bin", "test.png"]
        let correctExts = ["txt", "bin", "png"]
        let sampleFiles = sampleFileNames.map { File(fileName: $0) }
        for file in sampleFiles {
            XCTAssert(contains(correctExts, value: file.ext!), "contains extension")
        }
    }
    
    func testPngWrite() {
        let file = File(fileName: "test.png")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Png), "write png file")
        XCTAssert(Filer.rm(.Document, path: "test.png"), "delete png file")
    }
    
    func testJpgWrite() {
        let file = File(fileName: "test.jpg")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Jpeg(0.8)), "write jpg file")
        XCTAssert(Filer.rm(.Document, path: "test.jpg"), "delte jpg file")
    }
    
    func testPngRead() {
        let file = File(fileName: "test.png")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Png), "write png file")
        XCTAssertNotNil(FileReader(file: file).readImage(), "read png data")
        XCTAssert(Filer.rm(.Document, path: "test.png"), "delete png file")
    }

    func testJpegRead() {
        let file = File(fileName: "test.jpg")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Jpeg(0.2)), "write jpeg file")
        XCTAssertNotNil(FileReader(file: file).readImage(), "read jpeg data")
        XCTAssert(Filer.rm(.Document, path: "test.jpg"), "delte jpg file")
    }

    func testStoreDir() {
        XCTAssertEqual(StoreDirectory.Home.path(), NSHomeDirectory(), "home directory")
        XCTAssertEqual(StoreDirectory.Temp.path(), NSTemporaryDirectory(), "temp directory")
    }

    func testParsePath() {
        let (dirName1, fileName1) = File.parsePath("test/hoge.txt")
        XCTAssertEqual(dirName1!, "test", "dirName parse")
        XCTAssertEqual(fileName1, "hoge.txt", "fileName parse")
        let (dirName2, fileName2) = File.parsePath("test/test/hoge.txt")
        XCTAssertEqual(dirName2!, "test/test", "dirName parse")
        XCTAssertEqual(fileName2, "hoge.txt", "fileName parse")
    }

    func testAppendFile() {
        let file = File(fileName: "test.txt")
        let writer = FileWriter(file: file)
        writer.write("te")
        writer.appendString("st")
        XCTAssertEqual(FileReader(file: file).read(), "test")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete text file")
    }

    func testReadWriteMethod() {
        let file = File(fileName: "test.txt")
        XCTAssert(file.write("test"), "write string")
        XCTAssertEqual(file.read(), "test", "read string")
        XCTAssert(file.delete(), "delete file")
    }

    func testAppendOperator() {
        let file = File(fileName: "test.txt")
        file.write("te")
        XCTAssert("st" ->> file, "write oprator")
        XCTAssertEqual(file.read(), "test", "read string")
        XCTAssert(file.delete(), "delete file")
    }

    func testAppendOperatorIfNotExists() {
        let file = File(fileName: "test.txt")
        XCTAssert("test" ->> file, "write oprator")
        XCTAssertEqual(file.read(), "test", "read string")
        XCTAssert(file.delete(), "delete file")
    }

    func testWriteOperator() {
        let file = File(fileName: "test.txt")
        XCTAssert("test" --> file, "write oprator")
        XCTAssertEqual(file.read(), "test", "read string")
        XCTAssert(file.delete(), "delete file")
    }

    func testCat() {
        let file = File(fileName: "test.txt")
        XCTAssert("test" --> file, "write oprator")
        XCTAssertEqual(Filer.cat(.Document, path: "test.txt"), "test", "read string")
        let copyToFile = File(fileName: "test2.txt")
        XCTAssert(Filer.cat(.Document, path: "test.txt") --> copyToFile, "cat and write")
        XCTAssertEqual(copyToFile.read(), "test", "copy correctly")
        XCTAssert(file.delete(), "delete file")
        XCTAssert(copyToFile.delete(), "delete file")
    }
    
    func testNestedCp() {
        XCTAssert(Filer.touch(.Document, path: "test.txt"), "touch file")
        XCTAssert(Filer.mkdir(.Document, dirName: "hoge"), "create directory")
        XCTAssert(Filer.cp(.Document, srcPath: "test.txt", toPath: "hoge/test.txt"), "copy successfuly")
        XCTAssert(Filer.exists(.Document, path: "hoge/test.txt"), "exists files")
        XCTAssert(Filer.rm(.Document, path: "hoge/test.txt"), "delete files")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete origin file")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"))

        XCTAssert(Filer.mkdir(.Document, dirName: "hoge"))
        XCTAssert(Filer.touch(.Document, path: "hoge/test.txt"))
        XCTAssert(Filer.mkdir(.Document, dirName: "fuga"))
        XCTAssert(Filer.cp(.Document, srcPath: "hoge/test.txt", toPath: "fuga/test.txt"))
        XCTAssert(Filer.exists(.Document, path: "fuga/test.txt"), "copy successfuly")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"))
        XCTAssert(Filer.rmdir(.Document, dirName: "fuga"))
    }

    func testNestedMv() {
        XCTAssert(Filer.touch(.Document, path: "test.txt"), "touch file")
        XCTAssert(Filer.mkdir(.Document, dirName: "hoge"), "create directory")
        XCTAssert(Filer.mv(.Document, srcPath: "test.txt", toPath: "hoge/test.txt"), "copy successfuly")
        XCTAssertFalse(Filer.exists(.Document, path: "test.txt"), "moved file")
        XCTAssert(Filer.exists(.Document, path: "hoge/test.txt"), "exists files")
        XCTAssert(Filer.rm(.Document, path: "hoge/test.txt"), "delete files")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"))

        XCTAssert(Filer.mkdir(.Document, dirName: "hoge"))
        XCTAssert(Filer.touch(.Document, path: "hoge/test.txt"))
        XCTAssert(Filer.mkdir(.Document, dirName: "fuga"))
        XCTAssert(Filer.mv(.Document, srcPath: "hoge/test.txt", toPath: "fuga/test.txt"))
        XCTAssertFalse(Filer.exists(.Document, path: "hoge/test.txt"), "moved successfuly")
        XCTAssert(Filer.exists(.Document, path: "fuga/test.txt"), "copy successfuly")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"))
        XCTAssert(Filer.rmdir(.Document, dirName: "fuga"))
    }
    
    func testParseUrl() {
        Filer.mkdir(.Document, dirName: "hoge")
        let file = File(directory: .Document, path: "hoge/fuga.txt")
        let (dir, dirName, fileName) = File.parsePath(file.url.absoluteString!)!
        XCTAssertEqual(dir.path(), StoreDirectory.Document.path(), "parse StoreDirectory")
        XCTAssertEqual(dirName!, "/hoge", "parse dirName")
        XCTAssertEqual(fileName, "fuga.txt", "parse fileName")
        XCTAssert(Filer.rmdir(.Document, dirName: "hoge"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
