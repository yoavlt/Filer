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
    public static func withDir <T> (directory: StoreDirectory, f: (String, FileManager) -> T) -> T {
        let writePath = directory.path
        let fileManager = FileManager.default
        return f(writePath, fileManager)
    }

    public static func mkdir(directory: StoreDirectory, dirName: String) -> Bool {
        return withDir(directory: directory) { path, manager in
            let path = "\(path)/\(dirName)"
            do {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true)
                return true
            } catch {
                return false
            }
        }
    }

    public static func touch(directory: StoreDirectory, path: String) -> Bool {
        return FileWriter(file: File(directory: directory, path: path)).write(body: "")
    }

    public static func rm(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory: directory) { dirPath, manager in
            let filePath = "\(dirPath)/\(path)"
            do {
                try manager.removeItem(atPath: filePath)
                return true
            } catch {
                return false
            }
        }
    }

    public static func mv(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory: directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            do {
                try manager.moveItem(atPath: from, toPath: to)
                return true
            } catch {
                return false
            }
        }
    }

    public static func rmdir(directory: StoreDirectory, dirName: String) -> Bool {
        return rm(directory: directory, path: dirName)
    }

    public static func cp(directory: StoreDirectory, srcPath: String, toPath: String) -> Bool {
        return withDir(directory: directory) { path, manager in
            let from = "\(path)/\(srcPath)"
            let to = "\(path)/\(toPath)"
            do {
                try manager.copyItem(atPath: from, toPath: to)
                return true
            } catch {
                return false
            }
        }
    }

    public static func test(directory: StoreDirectory, path: String) -> Bool {
        return withDir(directory: directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            return manager.fileExists(atPath: path)
        }
    }

    public static func exists(directory: StoreDirectory, path: String) -> Bool {
        return test(directory: directory, path: path)
    }

    public static func ls(directory: StoreDirectory, dir: String = "") -> [File]? {
        return withDir(directory: directory) { dirPath, manager in
            let path = "\(dirPath)/\(dir)"
            do {
                return try manager.contentsOfDirectory(atPath: path).map { "\(dir)/\($0)"}
                    .map { path in File(directory: directory, path: path)}
            } catch {
                return nil
            }

        }
    }

    public static func cat(directory: StoreDirectory, path: String) -> String {
        return File(directory: directory, path: path).read()
    }

    public static func du(directory: StoreDirectory, path: String) -> UInt64 {
        return withDir(directory: directory) { dirPath, manager in
            let path = "\(dirPath)/\(path)"
            do {
                let attributes = try manager.attributesOfItem(atPath: path)
                let size = attributes[.size]
                return size as! UInt64
            } catch {
                return 0
            }
        }
    }
}
