//
//  GlobalColors.swift
//  HopliteChallenge
//
//  Created by Jeremy on 11/7/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func isDarkMode() -> Bool
    {
        if #available(iOS 13.0, *) {
            return (traitCollection.userInterfaceStyle == .dark)
        } else {
            return false
        }
    }
}

class DefaultTheme {
    class var primaryBG: UIColor {
        return UIColor.white
    }
    class var primaryText: UIColor {
        return UIColor.black
    }
    class var secondaryBG: UIColor {
        return UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
    }
    class var secondaryText: UIColor {
        return UIColor.white
    }
    class var tertiaryBG: UIColor {
        return UIColor.init(red: 0.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    class var tertiaryText: UIColor {
        return UIColor.white
    }
    class var quarternaryBG: UIColor {
        return UIColor.init(red: 120.0/255.0, green: 240.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    class var quarternaryText: UIColor {
        return UIColor.black
    }
    class var rowHighlightBG: UIColor {
        return UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    }
    class var menuButtonBG: UIColor {
        return tertiaryBG
    }
    class var menuButtonText: UIColor {
        return tertiaryText
    }
    class var menuButtonHistoryBG: UIColor {
        return secondaryBG
    }
    class var menuButtonHistoryText: UIColor {
        return secondaryText
    }
    
    class var continueButtonBG: UIColor {
        return tertiaryBG
    }
    class var continueButtonText: UIColor {
        return tertiaryText
    }
}

class DarkTheme:DefaultTheme {
    override class var primaryBG: UIColor {
        return UIColor.black
    }
    override class var primaryText: UIColor {
        return UIColor.white
    }
    override class var secondaryBG: UIColor {
        return UIColor.darkGray
    }
    override class var secondaryText: UIColor {
        return UIColor.white
    }
    override class var tertiaryBG: UIColor {
        return UIColor.init(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
    }
    override class var tertiaryText: UIColor {
        return UIColor.white
    }
    override class var quarternaryBG: UIColor {
        return UIColor.gray
    }
    override class var quarternaryText: UIColor {
        return UIColor.white
    }
    override class var rowHighlightBG: UIColor {
        return UIColor.darkGray
    }
    override class var menuButtonBG: UIColor {
        return secondaryBG
    }
    override class var menuButtonText: UIColor {
        return secondaryText
    }
    override class var menuButtonHistoryBG: UIColor {
        return tertiaryBG
    }
    override class var menuButtonHistoryText: UIColor {
        return tertiaryText
    }
    override class var continueButtonBG: UIColor {
        return secondaryBG
    }
    override class var continueButtonText: UIColor {
        return secondaryText
    }
}

var GlobalTheme:DefaultTheme.Type = DefaultTheme.self
//var GlobalTheme:DefaultTheme.Type = DefaultTheme.self
/*
class GlobalTheme  {
    static let shared = GlobalTheme()
    var colors:GlobalColors = GlobalColors
    private init() {
}
*/
/*
class GlobalColors: NSObject {
    class var lightModeRegularKey: UIColor { get { return UIColor.white } }
    class func regularKey(_ darkMode: Bool, solidColorMode: Bool) -> UIColor {
        if darkMode {
            if solidColorMode {
                return self.lightModeRegularKey //darkModeSolidColorRegularKey
            }
            else {
                return self.lightModeRegularKey //darkModeRegularKey
            }
        }
        else {
            return self.lightModeRegularKey //lightModeRegularKey
        }
    }
    
}
*/
