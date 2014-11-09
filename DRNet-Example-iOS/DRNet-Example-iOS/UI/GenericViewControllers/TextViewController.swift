//
//  TextViewController.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 09/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override convenience init() {
        self.init(nibName: "TextViewControllerView", bundle: nil)
    }
}
