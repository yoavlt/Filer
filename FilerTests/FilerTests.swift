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

    func testCopyFile() {
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
        for name in sampleFileNames {
            let file = Filer(fileName: name)
            FileWriter(file: file).write("test!!")
        }
        let files = Filer.ls(.Document, dir: "")!
        for file in files {
            XCTAssert(contains(sampleFileNames, value: file), "filename matches")
            Filer.rm(.Document, path: file)
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
    
    func testStoreDir() {
        XCTAssertEqual(StoreDirectory.Home.path(), NSHomeDirectory(), "home directory")
        XCTAssertEqual(StoreDirectory.Temp.path(), NSTemporaryDirectory(), "temp directory")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
