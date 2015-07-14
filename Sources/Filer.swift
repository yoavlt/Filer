//
//  Filer.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation

public class Filer {
    private let writePath: String
    public let directory: NSSearchPathDirectory
    public let fileName: String
    public var dirName: String? {
        didSet {
            if dirName != nil {
                Filer.mkdir(directory, dirName: dirName!)
            }
        }
    }

    public var dirPath: String {
        if let dirComp = dirName {
            return "\(writePath)/\(dirComp)"
        } else {
            return writePath
        }
    }

    public var path: String {
        get {
            return "\(dirPath)/\(fileName)"
        }
    }

    public var relativePath: String {
        get {
            if let dir = dirName {
                return "\(dir)/\(fileName)"
            } else {
                return fileName
            }
        }
    }

    public var isExists: Bool {
        get {
            return Filer.exists(directory, path: relativePath)
        }
    }

    public init(directory: NSSearchPathDirectory, dirName: String?, fileName: String) {
        self.directory = directory
        self.dirName = dirName
        self.fileName = fileName
        self.writePath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0] as! String
    }

    public convenience init(directory: NSSearchPathDirectory, fileName: String) {
        self.init(directory: directory, dirName: nil, fileName: fileName)
    }

    public convenience init(fileName: String) {
        self.init(directory: .DocumentDirectory, dirName: nil, fileName: fileName)
    }
    
    public func delete() -> Bool {
        return Filer.rm(directory, path: self.fileName)
    }
    
    public func copyTo(toPath: String) -> Bool {
        return Filer.cp(directory, srcPath: relativePath, toPath: toPath)
    }
    
    public func moveTo(toPath: String) -> Bool {
        return Filer.mv(directory, srcPath: relativePath, toPath: toPath)
    }

    // MARK: static methods
    public static func withDir <T> (directory: NSSearchPathDirectory, f: (String, NSFileManager) -> T) -> T {
        let writePath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0] as! String
        let fileManager = NSFileManager.defaultManager()
        return f(writePath, fileManager)
    }

    public static func mkdir(directory: NSSearchPathDirectory, dirName: String) -> Bool {
        return withDir(directory) { path, manager in
            let path = "\(path)/\(dirName)"
            return manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }

    public static func rm(directory: NSSearchPathDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let filePath = "\(dirPath)/\(path)"
            return manager.removeItemAtPath(filePath, error: nil)
        }
    }

    public static func mv(directory: NSSearchPathDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            return manager.moveItemAtPath(from, toPath: to, error: nil)
        }
    }

    public static func rmdir(directory: NSSearchPathDirectory, dirName: String) -> Bool {
        return rm(directory, path: dirName)
    }

    public static func cp(directory: NSSearchPathDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            return manager.copyItemAtPath(from, toPath: to, error: nil)
        }
    }

    public static func exists(directory: NSSearchPathDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            return manager.fileExistsAtPath(path)
        }
    }
}