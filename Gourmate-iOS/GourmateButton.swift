//
//  GourmateButton.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 7/8/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit

class GourmateButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let width = 300
        let height = 50
        self.frame.size = CGSize(width: width, height: height)
        layer.shadowRadius = 5.0
        
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = self.titleLabel?.text == "Group Analysis" ? UIColor.systemRed : UIColor.systemYellow
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.setCardView()
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
    }
    
}
