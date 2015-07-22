//
//  ViewController.swift
//  Filer
//
//  Created by Takuma Yoshida on 2015/07/13.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let file = Filer(fileName: "test.png")
        let image = UIImage(named: "heart")!
        FileWriter(file: file).writeImage(image, format: .Png)
        let readImage = FileReader(file: file).readImage()
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        imageView.image = readImage
        view.addSubview(imageView)
    }
    
    override func viewDidAppear(animated: Bool) {
        Filer.rm(.Document, path: "test.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

