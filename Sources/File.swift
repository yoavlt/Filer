//
//  File.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/22.
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

public class File : Printable, Equatable {
    private let writePath: String
    public let directory: StoreDirectory
    public let fileName: String
    public var dirName: String?

    public var dirPath: String {
        if let dirComp = dirName {
            if dirComp.isEmpty {
                return writePath
            }
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

    public var description: String {
        get {
            return "Filer \(self.path)"
        }
    }

    public init(directory: StoreDirectory, dirName: String?, fileName: String) {
        self.directory = directory
        if dirName != nil {
            self.dirName = Filer.toDirName(dirName!)
        }
        self.fileName = fileName
        self.writePath = directory.path()
    }

    public convenience init(directory: StoreDirectory, path: String) {
        if path.isEmpty {
            self.init(directory: StoreDirectory.Document, dirName: nil, fileName: "")
        } else {
            let (dirName, fileName) = Filer.parsePath(path)
            self.init(directory: directory, dirName: dirName, fileName: fileName)
        }
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
    
}

public func ==(lhs: File, rhs: File) -> Bool {
    return lhs.path == rhs.path
}