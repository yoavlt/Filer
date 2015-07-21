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
    public let file: Filer
    public init(file: Filer) {
        self.file = file
    }
    public func read() -> String {
        return readString()
    }
    public func readString() -> String {
        return NSString(contentsOfFile: file.path, encoding: NSUTF8StringEncoding, error: nil) as! String
    }
    public func readData() -> NSData? {
        return Filer.withDir(file.directory) { _, manager in
            return manager.contentsAtPath(self.file.path)
        }
    }
    public func readImage() -> UIImage? {
        return UIImage(contentsOfFile: file.path)
    }
}