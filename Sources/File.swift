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
    case SearchDirectory(FileManager.SearchPathDirectory)

    public var path: String {
        switch self {
        case .Home:
            return NSHomeDirectory()
        case .Temp:
            return NSTemporaryDirectory()
        case .Document:
            return StoreDirectory.SearchDirectory(.documentDirectory).path
        case .Cache:
            return StoreDirectory.SearchDirectory(.cachesDirectory).path
        case .Library:
            return StoreDirectory.SearchDirectory(.libraryDirectory).path
        case .Inbox:
            return "\(StoreDirectory.Library.path)/Inbox"
        case .SearchDirectory(let directory):
            return FileManager.default.urls(for: directory, in: .userDomainMask).first?.path ?? "/"
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

public class File : CustomStringConvertible, Equatable {
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
    
    public var url: URL {
        return URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
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
            return Filer.exists(directory: directory, path: relativePath)
        }
    }
    
    public var ext: String? {
        get {
            return fileName.split(separator: ".").last.map { String ($0) }
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
            self.dirName = File.toDirName(dirName: dirName!)
        }
        self.fileName = fileName
        self.writePath = directory.path
    }

    public convenience init(directory: StoreDirectory, path: String) {
        if path.isEmpty {
            self.init(directory: StoreDirectory.Document, dirName: nil, fileName: "")
        } else {
            let (dirName, fileName) = File.parsePath(string: path)
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
        let (dir, dirName, fileName) = File.parsePath(absoluteString: url.absoluteString!)!
        self.init(directory: dir, dirName: dirName, fileName: fileName)
    }

    public func delete() -> Bool {
        return Filer.rm(directory: directory, path: self.fileName)
    }
    
    public func copyTo(toPath: String) -> Bool {
        return Filer.cp(directory: directory, srcPath: relativePath, toPath: toPath)
    }
    
    public func moveTo(toPath: String) -> Bool {
        return Filer.mv(directory: directory, srcPath: relativePath, toPath: toPath)
    }
    
    public func read() -> String {
        return FileReader(file: self).read()
    }

    public func readData() -> Data? {
        return FileReader(file: self).readData()
    }

    public func readImage() -> UIImage? {
        return FileReader(file: self).readImage()
    }

    public func write(body: String) -> Bool {
        return FileWriter(file: self).write(body: body)
    }

    public func writeData(data: Data) -> Bool {
        return FileWriter(file: self).writeData(data: data)
    }
    
    public func writeImage(image: UIImage, format: ImageFormat) -> Bool {
        return FileWriter(file: self).writeImage(image: image, format: format)
    }

    public func append(body: String) -> Bool {
        if self.isExists == false {
            return FileWriter(file: self).write(body: body)
        }
        return FileWriter(file: self).append(body: body)
    }

    public func appendData(data: Data) -> Bool {
        if self.isExists == false {
            return FileWriter(file: self).writeData(data: data)
        }
        return FileWriter(file: self).appendData(data: data)
    }
    
    // MARK: static methods
    public static func parsePath(string: String) -> (String?, String) {
        let comps = string.components(separatedBy: "/")
        let fileName = comps.last!
        let dirName = comps.dropLast().joined(separator: "/")
        if dirName.isEmpty {
            return (nil, fileName)
        }
        return (dirName, fileName)
    }

    public static func parsePath(absoluteString: String) -> (StoreDirectory, String?, String)? {
        let comps = absoluteString.components(separatedBy: NSHomeDirectory())
        let names = Array(StoreDirectory.paths().keys)
        if let homeRelativePath = comps.last {
            let firstMatches = names.first { homeRelativePath.range(of: $0) != nil }
            if let name = firstMatches {
                if let dir = StoreDirectory.from(string: name) {
                    let path = homeRelativePath.replacingOccurrences(of: name, with: "")
                    let (dirName, fileName) = parsePath(string: path)
                    return (dir, dirName, fileName)
                }
            }
        }
        return nil
    }

    public static func toDirName(dirName: String) -> String {
        if dirName.hasSuffix("/") {
            return String(dirName.dropLast())
        } else {
            return dirName
        }
    }
}

public func ==(lhs: File, rhs: File) -> Bool {
    return lhs.path == rhs.path
}

infix operator ->>: AdditionPrecedence
infix operator -->: AdditionPrecedence

public func ->>(lhs: String, rhs: File) -> Bool {
    return rhs.append(body: lhs)
}

public func ->>(lhs: Data, rhs: File) -> Bool {
    return rhs.appendData(data: lhs)
}

public func -->(lhs: String, rhs: File) -> Bool {
    return rhs.write(body: lhs)
}

public func -->(lhs: Data, rhs: File) -> Bool {
    return rhs.writeData(data: lhs)
}
