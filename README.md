Filer: Simple file handler written in Swift
======================================

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

## Features
- Super easily handle file(copy, move, delete, test, ls...)
- Supports write/read Text and NSData
- Supports write/read UIImage(png, jpg)

## Installation
[CocoaPods](http://cocoapods.org) is a library manager for iOS projects. To install using CocoaPods:
```
pod 'Filer'
```
## Usage

### Supported commands
- `mkdir`
- `touch`
- `ls`
- `rm` / `rmdir`
- `mv`
- `cp`
- `exists` / `test`
- `cat`
- `du`

#### mkdir
```swift
Filer.mkdir(.Temp, dirName: "hoge") // create directory
```

#### touch / ls
```swift
Filer.touch(.Temp, path: "hoge.txt")
Filer.touch(.Temp, path: "fuga.txt")
Filer.ls(.Temp) // [File ("hoge.txt"), File ("fuga.txt")]
```

#### rm / rmdir
```swift
Filer.mkdir(.Temp, "hoge")
Filer.touch(.Temp, "hoge/test.txt")
Filer.rm(.Temp, "hoge/test.txt")
Filer.rmdir(.Temp, "hoge")
```

### mv
```swift
File(.Document, path: "hoge.txt").write("Awesome!")
Filer.mv(.Document, srcPath: "hoge.txt", "fuga.txt")
Filer.test(.Document, path: "hoge.txt") // false
Filer.test(.Document, path: "fuga.txt") // true
```

### cp
```swift
File(.Document, path: "hoge.txt").write("Awesome!")
Filer.cp(.Document, srcPath: "hoge.txt", toPath: "fuga.txt")
Filer.exists(.Document, path: "hoge.txt") // true
Filer.exists(.Document, path: "fuga.txt") // true
```

### cat
```swift
File(.Document, path: "hoge.txt").write("Awesome!")
Filer.cat(.Document, path: "hoge.txt") // "Awesome!"
```

### du
``` swift
File.du(.Document, path: "hoge.txt") // file size(bytes)
```

### write/read
```swift
let file = File(.Document, path: "sample.txt")
file.write("Awesome!") // write text
file.append("Wow!") // append string
file.read() // "Awesome!Wow!"
File(.Document, path: "sampleImage.png").writeImage(image, .Png) // write png
File(.Document, path: "sampleImage.jpg").writeImage(image, .Jpeg(0.8)) // write jpeg(quality: 0~1.0)
File(.document, path: "sampleImage.png").readImage() // -> UIImage
```

### Operator
```swift
jsonString --> File(.Document, path: "internal.json") // write text
let thumbnail = File(.Document, path: "thumbnail.png")
UIImagePNGRepresentation(image) --> thumbnail // write NSData

let file = File(.Document, path: "sample.txt")
file.write("Awesome!")
"Beautiful!" ->> file // append
file.read() // "Awesome!Beautiful!"
```

### List of directory
| Supported Directory | description       |
|---------------------|:------------------|
|.Temp                |Temporary directory|
|.Home                |Home direcotry     |
|.Document            |Document directory |
|.Cache               |Cache direcotry    |
|.Library             |Library directory  |
|.Inbox               |Inbox directory    |

## Requirements
- Xcode 6.3
- Swift 1.2 or above

## License
MIT License
