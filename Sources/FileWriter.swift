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
    public let file: Filer
    public init(file: Filer) {
        self.file = file
    }
    public func write(body: String) -> Bool {
        return writeString(body)
    }
    public func writeString(body: String) -> Bool {
        return body.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    public func writeData(data: NSData) -> Bool {
        return data.writeToFile(file.path, atomically: true)
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