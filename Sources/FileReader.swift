//
//  FileReader.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

public class FileReader {
    public let file: File
    public init(file: File) {
        self.file = file
    }
    public func read() -> String {
        return readString()
    }
    public func readString() -> String {
        do {
            return try String(contentsOfFile: file.path, encoding: .utf8)
        } catch {
            return ""
        }
    }
    public func readData() -> Data? {
        return Filer.withDir(directory: file.directory) { _, manager in
            return manager.contents(atPath: self.file.path)
        }
    }
    public func readImage() -> UIImage? {
        return UIImage(contentsOfFile: file.path)
    }
}
