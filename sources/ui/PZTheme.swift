//
//  PZTheme.swift
//  SynoTool
//
//  Created by Piotr on 19/01/2017.
//  Copyright © 2017 Piotr Zagawa. All rights reserved.
//

import Foundation

@objc class PZTheme: NSObject
{
    static func updateDarkMode()
    {
        var darkMode = false
        
        if let map = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        {
            if let mode = map["AppleInterfaceStyle"]
            {
                if let modeText = mode as? String
                {
                    if (modeText.caseInsensitiveCompare("dark") == ComparisonResult.orderedSame)
                    {
                        darkMode = true
                    }
                }
            }
        }

        self.isDarkMode = darkMode
    }
    
    static var isDarkMode: Bool = false
    
    static var backgroundColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) : NSColor.white
    }
    
    static var systemAdminTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.2, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
    }

    static var systemOSUpgradeTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0) : NSColor(calibratedRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
    }
    
    static var sectionHeaderTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.75, blue: 0.25, alpha: 1.0) : NSColor(calibratedRed: 0.36, green: 0.18, blue: 0.0, alpha: 1.0)
    }

    static var sectionTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.5, alpha: 1.0) : NSColor(calibratedWhite: 0.4, alpha: 1.0)
    }

    static var sectionValueColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.9, alpha: 1.0) : NSColor(calibratedWhite: 0.2, alpha: 1.0)
    }
    
    static var systemSystemStatusTagNormalColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.3, green: 0.6, blue: 0.2, alpha: 1.0) : NSColor(calibratedRed: 0.4, green: 0.9, blue: 0.4, alpha: 1.0)
    }

    static var systemSystemStatusTagErrorColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.3, blue: 0.4, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.5, blue: 0.6, alpha: 1.0)
    }

    static var systemSystemStatusTagNullColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) : NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }

    static var defaultBarBkgColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.22, alpha: 1.0) : NSColor(calibratedWhite: 0.92, alpha: 1.0)
    }

    static var defaultBar050Color: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0, green: 0.8, blue: 0.2, alpha: 1.0) : NSColor(calibratedRed: 0, green: 0.9, blue: 0.5, alpha: 1.0)
    }

    static var defaultBar075Color: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.1, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.75, blue: 0.5, alpha: 1.0)
    }

    static var defaultBar100Color: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.3, blue: 0.4, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
    }

    static var valueTagNormalColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) : NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    }

    static var valueProgressTagColor: NSColor
    {
        let color = barStateProgressColor
        
        return (self.isDarkMode ? color.shadow(withLevel: 0.6) : color.highlight(withLevel: 0.3))!
    }

    static var valueCompletedTagColor: NSColor
    {
        let color = barStateCompletedColor
        
        return (self.isDarkMode ? color.shadow(withLevel: 0.6) : color.highlight(withLevel: 0.3))!
    }
    
    static var connectionTypeTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) : NSColor(calibratedRed: 0.0, green: 0.45, blue: 0.9, alpha: 1.0)
    }

    static var connectionFromTextColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.3, green: 0.4, blue: 0.8, alpha: 1.0) : NSColor(calibratedRed: 0.0, green: 0.3, blue: 0.5, alpha: 1.0)
    }
    
    static var buttonBackgroundColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.22, alpha: 1.0) : NSColor(calibratedWhite: 0.9, alpha: 1.0)
    }

    static var buttonSymbolColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.8, alpha: 1.0) : NSColor(calibratedWhite: 0.5, alpha: 1.0)
    }

    static var buttonDisabledSymbolColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.5, alpha: 1.0) : NSColor(calibratedWhite: 0.7, alpha: 1.0)
    }

    static var barStateProgressColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.1, green: 0.45, blue: 0.8, alpha: 1.0) : NSColor(calibratedRed: 0.35, green: 0.7, blue: 1.0, alpha: 1.0)
    }

    static var barStateErrorColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 1.0, green: 0.3, blue: 0.4, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
    }

    static var barStatePauseColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0.8, green: 0.5, blue: 0.2, alpha: 1.0) : NSColor(calibratedRed: 1.0, green: 0.75, blue: 0.5, alpha: 1.0)
    }

    static var barStateCompletedColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedRed: 0, green: 0.65, blue: 0.3, alpha: 1.0) : NSColor(calibratedRed: 0, green: 0.9, blue: 0.6, alpha: 1.0)
    }

    static var barStateInactiveColor: NSColor
    {
        return self.isDarkMode ? NSColor(calibratedWhite: 0.45, alpha: 1.0) : NSColor(calibratedWhite: 0.7, alpha: 1.0)
    }

}
