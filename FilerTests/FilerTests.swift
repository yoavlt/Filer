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
        let file = Filer(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssertEqual(FileReader(file: file).read(), "test!!", "write body correctly")
        XCTAssert(file.delete(), "delete file")
        XCTAssertFalse(file.isExists, "test delete file")
    }

    func testTouchCommand() {
        XCTAssert(Filer.touch(.Document, path: "test.txt"), "touch file")
        let file = Filer(fileName: "test.txt")
        XCTAssert(file.delete(), "delete file")
        XCTAssertFalse(file.isExists, "test delete file")
    }

    func testCopyFile() {
        Filer.rm(.Document, path: "test2.txt")
        let file = Filer(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssert(Filer.cp(.Document, srcPath: "test.txt", toPath: "test2.txt"), "copy file successfuly")
        XCTAssert(Filer.exists(.Document, path: "test.txt"), "test dupliated")
        XCTAssert(Filer.exists(.Document, path: "test2.txt"), "test dupliated")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete file")
        XCTAssert(Filer.rm(.Document, path: "test2.txt"), "delete file")
    }

    func testMoveFile() {
        let file = Filer(directory: .Document, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(Filer.mv(.Document, srcPath: "test.txt", toPath: "test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(Filer(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.Document, path: "test4.txt"), "delete file")
    }
    
    func testMoveMethodFile() {
        let file = Filer(directory: .Document, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(file.moveTo("test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(Filer(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.Document, path: "test4.txt"), "delete file")
    }

    func testCopyMethods() {
        let file = Filer(fileName: "test.txt")
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
        let sampleFiles = sampleFileNames.map { Filer(fileName: $0) }
        for file in sampleFiles {
            FileWriter(file: file).write("test!!")
        }
        let files = Filer.ls(.Document, dir: "")!
        for file in files {
            XCTAssert(contains(sampleFiles, value: file), "filename matches")
            Filer.rm(StoreDirectory.Document, path: file.fileName)
        }
    }
    
    func testExt() {
        let sampleFileNames = ["test.txt", "test.bin", "test.png"]
        let correctExts = ["txt", "bin", "png"]
        let sampleFiles = sampleFileNames.map { Filer(fileName: $0) }
        for file in sampleFiles {
            XCTAssert(contains(correctExts, value: file.ext!), "contains extension")
        }
    }
    
    func testPngWrite() {
        let file = Filer(fileName: "test.png")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Png), "write png file")
        XCTAssert(Filer.rm(.Document, path: "test.png"), "delete png file")
    }
    
    func testJpgWrite() {
        let file = Filer(fileName: "test.jpg")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Jpeg(0.8)), "write jpg file")
        XCTAssert(Filer.rm(.Document, path: "test.jpg"), "delte jpg file")
    }
    
    func testPngRead() {
        let file = Filer(fileName: "test.png")
        let image = UIImage(named: "heart")!
        XCTAssert(FileWriter(file: file).writeImage(image, format: .Png), "write png file")
        XCTAssertNotNil(FileReader(file: file).readImage(), "read png data")
        XCTAssert(Filer.rm(.Document, path: "test.png"), "delete png file")
    }

    func testJpegRead() {
        let file = Filer(fileName: "test.jpg")
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
        let (dirName1, fileName1) = Filer.parsePath("test/hoge.txt")
        XCTAssertEqual(dirName1, "test", "dirName parse")
        XCTAssertEqual(fileName1, "hoge.txt", "fileName parse")
        let (dirName2, fileName2) = Filer.parsePath("test/test/hoge.txt")
        XCTAssertEqual(dirName2, "test/test", "dirName parse")
        XCTAssertEqual(fileName2, "hoge.txt", "fileName parse")
    }

    func testAppendFile() {
        let file = Filer(fileName: "test.txt")
        let writer = FileWriter(file: file)
        writer.write("te")
        writer.appendString("st")
        XCTAssertEqual(FileReader(file: file).read(), "test")
        XCTAssert(Filer.rm(.Document, path: "test.txt"), "delete text file")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
