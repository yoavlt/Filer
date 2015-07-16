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
        XCTAssert(Filer.mkdir(.DocumentDirectory, dirName: "hoge"), "create directory successfuly")
        XCTAssert(Filer.exists(.DocumentDirectory, path: "hoge"), "exists diretory")
        XCTAssert(Filer.rmdir(.DocumentDirectory, dirName: "hoge"), "delete directory successfuly")
        XCTAssertFalse(Filer.exists(.DocumentDirectory, path: "hoge"), "didn't exists diretory")
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
        XCTAssert(Filer.cp(.DocumentDirectory, srcPath: "test.txt", toPath: "test2.txt"), "copy file successfuly")
        XCTAssert(Filer.exists(.DocumentDirectory, path: "test.txt"), "test dupliated")
        XCTAssert(Filer.exists(.DocumentDirectory, path: "test2.txt"), "test dupliated")
        XCTAssert(Filer.rm(.DocumentDirectory, path: "test.txt"), "delete file")
        XCTAssert(Filer.rm(.DocumentDirectory, path: "test2.txt"), "delete file")
    }

    func testMoveFile() {
        let file = Filer(directory: .DocumentDirectory, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(Filer.mv(.DocumentDirectory, srcPath: "test.txt", toPath: "test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(Filer(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.DocumentDirectory, path: "test4.txt"), "delete file")
    }
    
    func testMoveMethodFile() {
        let file = Filer(directory: .DocumentDirectory, fileName: "test.txt")
        XCTAssert(FileWriter(file: file).write("test!!"), "write file")
        XCTAssert(file.isExists, "write file")
        XCTAssert(file.moveTo("test4.txt"), "move file successfuly")
        XCTAssertFalse(file.isExists, "moved file")
        XCTAssert(Filer(fileName: "test4.txt").isExists, "moved")
        XCTAssert(Filer.rm(.DocumentDirectory, path: "test4.txt"), "delete file")
    }

    func testCopyMethods() {
        let file = Filer(fileName: "test.txt")
        FileWriter(file: file).write("test!!")
        XCTAssert(file.copyTo("test2.txt"), "copy file successfuly")
        XCTAssert(Filer.exists(.DocumentDirectory, path: "test.txt"), "test dupliated")
        XCTAssert(Filer.exists(.DocumentDirectory, path: "test2.txt"), "test dupliated")
        XCTAssert(file.delete(), "delete successfuly")
        XCTAssert(Filer.rm(.DocumentDirectory, path: "test2.txt"), "delete file")
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
        let files = Filer.ls(.DocumentDirectory, dir: "")!
        for file in files {
            XCTAssert(contains(sampleFileNames, value: file), "filename matches")
            Filer.rm(.DocumentDirectory, path: file)
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
