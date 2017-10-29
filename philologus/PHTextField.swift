//
//  PHTextField.swift
//  philolog.us
//
//  Created by Jeremy March on 10/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class PHTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.bounds.size.width - 36, y: 0, width: 40, height: 38)
    }
}
