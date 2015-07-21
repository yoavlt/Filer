//
//  Filer.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation

public enum StoreDirectory {
    case Home
    case Temp
    case Document
    case Cache
    case Inbox
    case Library
    case SearchDirectory(NSSearchPathDirectory)

    public func path() -> String {
        switch self {
        case .Home:
            return NSHomeDirectory()
        case .Temp:
            return NSTemporaryDirectory()
        case .Document:
            return StoreDirectory.SearchDirectory(.DocumentDirectory).path()
        case .Cache:
            return StoreDirectory.SearchDirectory(.CachesDirectory).path()
        case .Library:
            return StoreDirectory.SearchDirectory(.LibraryDirectory).path()
        case .Inbox:
            return "\(StoreDirectory.Library.path())/Inbox"
        case .SearchDirectory(let searchPathDirectory):
            return NSSearchPathForDirectoriesInDomains(searchPathDirectory, .UserDomainMask, true)[0] as! String
        default:
            return "/"
        }
    }
}

public class Filer {
    private let writePath: String
    public let directory: StoreDirectory
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

    public var url: NSURL {
        get {
            return NSURL(fileURLWithPath: self.path)!
        }
    }
    
    public var ext: String? {
        get {
            return split(fileName, isSeparator: { $0 == "." }).last
        }
    }

    public init(directory: StoreDirectory, dirName: String?, fileName: String) {
        self.directory = directory
        self.dirName = dirName
        self.fileName = fileName
        self.writePath = directory.path()
    }

    public convenience init(directory: StoreDirectory, fileName: String) {
        self.init(directory: directory, dirName: nil, fileName: fileName)
    }

    public convenience init(fileName: String) {
        self.init(directory: StoreDirectory.Document, dirName: nil, fileName: fileName)
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
    public static func withDir <T> (directory: StoreDirectory, f: (String, NSFileManager) -> T) -> T {
        let writePath = directory.path()
        let fileManager = NSFileManager.defaultManager()
        return f(writePath, fileManager)
    }

    public static func mkdir(directory: StoreDirectory, dirName: String) -> Bool {
        return withDir(directory) { path, manager in
            let path = "\(path)/\(dirName)"
            return manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }

    public static func rm(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let filePath = "\(dirPath)/\(path)"
            return manager.removeItemAtPath(filePath, error: nil)
        }
    }

    public static func mv(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            return manager.moveItemAtPath(from, toPath: to, error: nil)
        }
    }

    public static func rmdir(directory: StoreDirectory, dirName: String) -> Bool {
        return rm(directory, path: dirName)
    }

    public static func cp(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            return manager.copyItemAtPath(from, toPath: to, error: nil)
        }
    }

    public static func exists(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            return manager.fileExistsAtPath(path)
        }
    }

    public static func ls(directory: StoreDirectory, dir: String) -> [String]? {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(dir)"
            return manager.contentsOfDirectoryAtPath(path, error: nil)?.map { $0 as! String }
        }
    }

    public static func parsePath(string: String) -> (String, String) {
        let comps = string.componentsSeparatedByString("/")
        let fileName = comps.last!
        let dirName = join("/", dropLast(comps))
        return (dirName, fileName)
    }

}