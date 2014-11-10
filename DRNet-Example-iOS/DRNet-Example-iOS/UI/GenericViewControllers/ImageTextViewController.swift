//
//  ImageTextViewController.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 10/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit

class ImageTextViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override convenience init() {
        self.init(nibName: "ImageTextViewControllerView", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = nil
        label.text = nil
    }
    
}