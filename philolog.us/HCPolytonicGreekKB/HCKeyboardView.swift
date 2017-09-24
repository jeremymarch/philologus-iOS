//
//  HCKeyboardView.swift
//  HCPolytonicGreekKBapp
//
//  Created by Jeremy March on 9/14/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

//this is for iOS 8.4 and below: https://stackoverflow.com/questions/24756018/custom-inputview-with-dynamic-height-in-ios-8
class HCKeyboardView: UIInputView {
    var buttons:[[UIButton]] = []
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var intrinsicHeight: CGFloat = 174 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    init() {
        super.init(frame: CGRect(), inputViewStyle: .keyboard)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.intrinsicHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewWidth:CGFloat = self.bounds.width
        let viewHeight:CGFloat = self.bounds.height
        
        //NSLog("layout subviews height: \(viewHeight)")
        
        var maxColumns = 0
        for (_, row) in buttons.enumerated()
        {
            var c = 0
            var xCount = 0
            for a in row {
                if a.titleLabel!.text == "xxx"
                {
                    xCount += 1
                }
            }
            c = row.count - xCount
            if c > maxColumns
            {
                maxColumns = c
            }
        }
        let maxRows = buttons.count
        var buttonHSpacing:CGFloat = 5.0
        let buttonVSpacing:CGFloat = 5.0
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            buttonHSpacing = 6.0
        }
        else
        {
            if maxColumns > 9
            {
                buttonHSpacing = 4.0
            }
            else
            {
                buttonHSpacing = 5.0
            }
        }
        var c = 0
        var xoffstart:CGFloat = 0
        var xoff:CGFloat = 0
        var buttonWidth:CGFloat = 0
        var buttonHeight:CGFloat = 0
        
        for (i, row) in buttons.enumerated()
        {
            var xCount = 0
            for a in row {
                if a.titleLabel!.text == "xxx"
                {
                    xCount += 1
                }
            }
            
            c = row.count - xCount
            xoffstart = 0
            xoff = 0
            
            buttonWidth = (viewWidth - (buttonHSpacing * CGFloat(maxColumns))) / CGFloat(maxColumns)
            buttonHeight = (viewHeight - (buttonVSpacing * (CGFloat(maxRows) + 1.0))) / CGFloat(maxRows)
            
            if c < maxColumns
            {
                xoffstart = ((buttonWidth + buttonHSpacing) / 2.0) * CGFloat(maxColumns - c) + (buttonHSpacing / 2)
            }
            else
            {
                xoffstart = (buttonHSpacing / 2)
            }
            xoff = xoffstart
            var x = false //skip one
            for a in row {
                if a.titleLabel?.text == "enter" || a.titleLabel?.text == "space"
                {
                    if !x
                    {
                        x = true
                        continue
                    }
                    xoff -= (buttonWidth * 2.6) - buttonWidth
                }
            }
            for (j, key) in row.enumerated()
            {
                if key.titleLabel?.text == "xxx"
                {
                    key.isHidden = true
                }
                else
                {
                    key.isHidden = false
                    if i == 2 && j == 7 //delete
                    {
                        if UIDevice.current.userInterfaceIdiom == .pad
                        {
                            key.frame = CGRect(x: xoff, y: (CGFloat(i) * (buttonVSpacing + buttonHeight)) + buttonVSpacing, width: buttonWidth, height: buttonHeight)
                            xoff += buttonHSpacing + buttonWidth
                        }
                        else
                        {
                            key.frame = CGRect(x: xoff, y: (CGFloat(i) * (buttonVSpacing + buttonHeight)) + buttonVSpacing, width: buttonHeight, height: buttonHeight)
                            xoff += buttonHSpacing + buttonHeight
                        }
                    }
                    else if key.titleLabel?.text == "enter" || key.titleLabel?.text == "space"
                    {
                        key.frame = CGRect(x: xoff, y: (CGFloat(i) * (buttonVSpacing + buttonHeight)) + buttonVSpacing, width: buttonWidth * 2.6, height: buttonHeight)
                        xoff += buttonHSpacing + (buttonWidth * 2.6)
                    }
                    else
                    {
                        //let aa = key as! HCButton
                        var buttonDown = false
                        if let aa = key as? HCButton
                        {
                            if aa.buttonDown
                            {
                                buttonDown = true
                            }
                        }
                        
                        if buttonDown
                        {
                            let aa = key as! HCButton
                            let width2 = buttonWidth * aa.buttonDownWidthFactor
                            let height2 = (buttonHeight * aa.buttonDownHeightFactor) + aa.buttonTail
                            let x2 = xoff - (((buttonWidth * aa.buttonDownWidthFactor) - buttonWidth) / 2)
                            let y2 = ((CGFloat(i) * (buttonVSpacing + buttonHeight)) + buttonVSpacing) - height2 + buttonHeight + aa.buttonTail
                            
                            key.frame = CGRect(x: x2, y: y2, width: width2, height: height2)
                            key.superview?.bringSubview(toFront: key)
                            xoff += (buttonHSpacing + buttonWidth)
                        }
                        else
                        {
                            key.frame = CGRect(x: xoff, y: (CGFloat(i) * (buttonVSpacing + buttonHeight)) + buttonVSpacing, width: buttonWidth, height: buttonHeight)
                            xoff += (buttonHSpacing + buttonWidth)
                        }
                    }
                }
                //key.setNeedsDisplay() //needed for iOS 8.4 when app extension
                //commented out, setting contentMode of button to .redraw achieves same thing.
                //https://stackoverflow.com/questions/13434794/calling-setneedsdisplay-in-layoutsubviews
            }
        }
    }
}

