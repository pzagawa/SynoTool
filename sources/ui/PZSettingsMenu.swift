//
//  PZSettingsMenu.swift
//  SynoTool
//
//  Created by Piotr on 05/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZSettingsMenu: NSObject, NSMenuDelegate
{
    enum MenuItemType: Int
    {
        case MenuItemTypeAddDevice
        case MenuItemTypeDevice
        case MenuItemTypeLabel
        case MenuItemTypeSettings
        case MenuItemTypeSupport
        case MenuItemTypeQuit
        case MenuItemTypeSeparator
    }

    typealias OnClickBlock = (_ sender: NSMenuItem, _ menuItemType: MenuItemType?) -> Void
    typealias OnIsMenuItemEnabled = (_ sender: NSMenuItem, _ menuItemType: MenuItemType?) -> Bool

    var onClickBlock: OnClickBlock? = nil
    var onIsMenuItemEnabled: OnIsMenuItemEnabled? = nil

    private let menu = NSMenu()
    
    var devicesCount = 0

    override init()
    {
        super.init()
        
        self.menu.delegate = self
        
        self.recreateMenu()
    }

    private func newMenuItem(menuItemType: MenuItemType, title: String?) -> NSMenuItem
    {
        var menuItem: NSMenuItem? = nil
        
        if (title == nil)
        {
            menuItem = NSMenuItem.separator()
        }
        else
        {
            let action = #selector(onMenuItemClick)
            
            menuItem = NSMenuItem(title: title!, action: action, keyEquivalent: "")
        }
        
        menuItem?.target = self
        menuItem?.tag = menuItemType.rawValue
        
        return menuItem!
    }
    
    @objc private func onMenuItemClick(sender: NSMenuItem)
    {
        if let block = self.onClickBlock
        {
            let menuItemType = MenuItemType(rawValue: sender.tag)
            
            block(sender, menuItemType)
        }
    }

    private func recreateMenu()
    {
        self.menu.removeAllItems()
        
        if (self.devicesCount == 0)
        {
            self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeAddDevice, title: "Add Device"))
        }
        else
        {
            self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeLabel, title: "Devices:"))
            self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeDevice, title: "PZDRIVE1"))
            self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeDevice, title: "PZDRIVE2"))
            self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeDevice, title: "PZDRIVE3"))
        }
        
        self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeSeparator, title: nil))
        self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeSettings, title: "Settings"))
        self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeSupport, title: "Support"))
        self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeSeparator, title: nil))
        self.menu.addItem(self.newMenuItem(menuItemType: .MenuItemTypeQuit, title: "Quit"))
    }

    func openMenu(view: NSView)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            let y = -6
            
            let location = NSPoint(x: 0, y: y)

            if let this = self
            {
                this.menu.popUp(positioning: nil, at: location, in: view)
            }
        }
    }
    
    func menuWillOpen(_ menu: NSMenu)
    {
        self.recreateMenu()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        let menuItemType = MenuItemType(rawValue: menuItem.tag)

        if (menuItemType == .MenuItemTypeLabel)
        {
            return false
        }

        if (menuItemType == .MenuItemTypeSeparator)
        {
            return false
        }
        
        if let block = self.onIsMenuItemEnabled
        {
            return block(menuItem, menuItemType)
        }

        return true;
    }
    
}
