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
        return writeString(body: body)
    }

    public func append(body: String) -> Bool {
        return appendString(body: body)
    }

    public func writeString(body: String) -> Bool {
        do {
            try body.write(toFile: file.path, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    public func appendString(body: String) -> Bool {
        if let data = body.data(using: .utf8) {
            return appendData(data: data)
        }
        return false
    }

    public func writeData(data: Data) -> Bool {
        do {
            try data.write(to: file.url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    public func appendData(data: Data) -> Bool {
        return withHandler(path: file.path) { handle in
            handle.seekToEndOfFile()
            handle.write(data)
        }
    }

    public func withHandler(path: String, f: (FileHandle) -> ()) -> Bool {
        if let handler = FileHandle(forWritingAtPath: path) {
            f(handler)
            handler.closeFile()
            return true
        }
        return false
    }

    public func writeImage(image: UIImage, format: ImageFormat) -> Bool {
        if let data = imageToData(image: image, format: format) {
            return writeData(data: data)
        } else {
            return false
        }
    }

    private func imageToData(image: UIImage, format: ImageFormat) -> Data? {
        switch format {
        case .Png:
            return image.pngData()
        case .Jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        }
    }
}
