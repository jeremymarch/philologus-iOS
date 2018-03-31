//
//  PHTitleView.swift
//  philolog.us
//
//  Created by Jeremy March on 10/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class PHTitleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewWidth:CGFloat = self.bounds.width
        let viewHeight:CGFloat = self.bounds.height

        for v in subviews
        {
            if v is UITextField
            {
                if subviews.count < 2
                {
                    v.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
                }
                else
                {
                //v.frame = CGRect(x: 26, y: 0, width: viewWidth - 26.0, height: viewHeight)
                    v.frame = CGRect(x: 0, y: 0, width: viewWidth - 44.0, height: viewHeight)
                }
            }
            else if v is UIButton
            {
                //v.frame = CGRect(x: -10, y: 0, width: 38.0, height: viewHeight)
                v.frame = CGRect(x: viewWidth - 26.0, y: 0, width: 26.0, height: viewHeight)
            }
        }
    }
}
