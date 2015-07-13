//
//  FileReader.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation

public class FileReader {
    public let file: Filer
    public init(file: Filer) {
        self.file = file
    }
    public func read() -> String {
        return NSString(contentsOfFile: file.path, encoding: NSUTF8StringEncoding, error: nil) as! String
    }
}