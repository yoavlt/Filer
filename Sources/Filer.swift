//
//  Filer.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation

public class Filer {
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

    public static func touch(directory: StoreDirectory, path: String) -> Bool {
        return FileWriter(file: File(directory: directory, path: path)).write("")
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

    public static func test(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            return manager.fileExistsAtPath(path)
        }
    }

    public static func exists(directory: StoreDirectory, path: String) -> Bool {
        return test(directory, path: path)
    }

    public static func ls(directory: StoreDirectory, dir: String = "") -> [File]? {
        return withDir(directory) { dirPath, manager in
            let path = "\(dirPath)/\(dir)"
            return manager.contentsOfDirectoryAtPath(path, error: nil)?.map { "\(dir)/\($0 as! String)" }
                .map { path in File(directory: directory, path: path) }
        }
    }

    public static func cat(directory: StoreDirectory, path: String) -> String {
        return File(directory: directory, path: path).read()
    }
}
