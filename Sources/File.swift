//
//  File.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/22.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

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

    static public func from(string: String) -> StoreDirectory? {
        return StoreDirectory.paths()[string]
    }
    
    static public func paths() -> [String : StoreDirectory] {
        return [
            "/" : .Home,
            "/tmp": .Temp,
            "/Documents": .Document,
            "/Caches": .Cache,
            "/Library": .Library,
            "/Library/Inbox": .Inbox
        ]
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
            return "File \(self.path)"
        }
    }

    public init(directory: StoreDirectory, dirName: String?, fileName: String) {
        self.directory = directory
        if dirName != nil {
            self.dirName = File.toDirName(dirName!)
        }
        self.fileName = fileName
        self.writePath = directory.path()
    }

    public convenience init(directory: StoreDirectory, path: String) {
        if path.isEmpty {
            self.init(directory: StoreDirectory.Document, dirName: nil, fileName: "")
        } else {
            let (dirName, fileName) = File.parsePath(path)
            self.init(directory: directory, dirName: dirName, fileName: fileName)
        }
    }

    public convenience init(directory: StoreDirectory, fileName: String) {
        self.init(directory: directory, dirName: nil, fileName: fileName)
    }

    public convenience init(fileName: String) {
        self.init(directory: StoreDirectory.Document, dirName: nil, fileName: fileName)
    }

    public convenience init(url: NSURL) {
        let (dir, dirName, fileName) = File.parsePath(url.absoluteString!)!
        self.init(directory: dir, dirName: dirName, fileName: fileName)
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
    
    public func read() -> String {
        return FileReader(file: self).read()
    }

    public func readData() -> NSData? {
        return FileReader(file: self).readData()
    }

    public func readImage() -> UIImage? {
        return FileReader(file: self).readImage()
    }

    public func write(body: String) -> Bool {
        return FileWriter(file: self).write(body)
    }

    public func writeData(data: NSData) -> Bool {
        return FileWriter(file: self).writeData(data)
    }
    
    public func writeImage(image: UIImage, format: ImageFormat) -> Bool {
        return FileWriter(file: self).writeImage(image, format: format)
    }

    public func append(body: String) -> Bool {
        if self.isExists == false {
            return FileWriter(file: self).write(body)
        }
        return FileWriter(file: self).append(body)
    }

    public func appendData(data: NSData) -> Bool {
        if self.isExists == false {
            return FileWriter(file: self).writeData(data)
        }
        return FileWriter(file: self).appendData(data)
    }
    
    // MARK: static methods
    public static func parsePath(string: String) -> (String?, String) {
        let comps = string.componentsSeparatedByString("/")
        let fileName = comps.last!
        let dirName = join("/", dropLast(comps))
        if dirName.isEmpty {
            return (nil, fileName)
        }
        return (dirName, fileName)
    }

    public static func parsePath(absoluteString: String) -> (StoreDirectory, String?, String)? {
        let comps = absoluteString.componentsSeparatedByString(NSHomeDirectory())
        let names = Array(StoreDirectory.paths().keys)
        if let homeRelativePath = comps.last {
            let firstMathes = names.filter { homeRelativePath.rangeOfString($0) != nil }.first
            if let name = firstMathes {
                if let dir = StoreDirectory.from(name) {
                    let path = homeRelativePath.stringByReplacingOccurrencesOfString(name, withString: "", options: .LiteralSearch, range: nil)
                    let (dirName, fileName) = parsePath(path)
                    return (dir, dirName, fileName)
                }
            }
        }
        return nil
    }

    public static func toDirName(dirName: String) -> String {
        switch Array(dirName).last {
        case .Some("/"):
            return dropLast(dirName)
        default:
            return dirName
        }
    }
}

public func ==(lhs: File, rhs: File) -> Bool {
    return lhs.path == rhs.path
}

infix operator ->> { associativity left }

public func ->>(lhs: String, rhs: File) -> Bool {
    return rhs.append(lhs)
}

public func ->>(lhs: NSData, rhs: File) -> Bool {
    return rhs.appendData(lhs)
}

infix operator --> { associativity left }

public func -->(lhs: String, rhs: File) -> Bool {
    return rhs.write(lhs)
}

public func -->(lhs: NSData, rhs: File) -> Bool {
    return rhs.writeData(lhs)
}