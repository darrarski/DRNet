//
//  MenuItemCell.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 10/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private let borderColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    private let alternativeColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cleanUp()
        
        let borderView = UIView()
        borderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        borderView.backgroundColor = borderColor
        addSubview(borderView)
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[border]|",
                options: .allZeros,
                metrics: nil,
                views: [
                    "border": borderView
                ]
            )
        )

        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[border(size)]|",
                options: .allZeros,
                metrics: [
                    "size": 0.5
                ],
                views: [
                    "border": borderView
                ]
            )
        )

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cleanUp()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        UIView.animateWithDuration({ animated ? 0.5 : 0 }(), animations: { () -> Void in
            self.backgroundColor = highlighted ? self.alternativeColor : UIColor.clearColor()
        })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        setHighlighted(selected, animated: animated)
    }
    
    private func cleanUp() {
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
}