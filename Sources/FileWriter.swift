//
//  FileWriter.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

public enum ImageFormat {
    case Png
    case Jpeg(CGFloat)
}

public class FileWriter {
    public let file: File
    public init(file: File) {
        self.file = file
    }

    public func write(body: String) -> Bool {
        return writeString(body)
    }

    public func append(body: String) -> Bool {
        return appendString(body)
    }

    public func writeString(body: String) -> Bool {
        return body.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }

    public func appendString(body: String) -> Bool {
        if let data = body.dataUsingEncoding(NSUTF8StringEncoding) {
            return appendData(data)
        }
        return false
    }

    public func writeData(data: NSData) -> Bool {
        return data.writeToFile(file.path, atomically: true)
    }

    public func appendData(data: NSData) -> Bool {
        return withHandler(file.path) { handle in
            handle.seekToEndOfFile()
            handle.writeData(data)
        }
    }

    public func withHandler(path: String, f: (NSFileHandle) -> ()) -> Bool {
        if let handler = NSFileHandle(forWritingAtPath: path) {
            f(handler)
            handler.closeFile()
            return true
        }
        return false
    }

    public func writeImage(image: UIImage, format: ImageFormat) -> Bool {
        let data = imageToData(image, format: format)
        return writeData(data)
    }

    private func imageToData(image: UIImage, format: ImageFormat) -> NSData {
        switch format {
        case .Png:
            return UIImagePNGRepresentation(image)
        case .Jpeg(let quality):
            return UIImageJPEGRepresentation(image, quality)
        }
    }
}