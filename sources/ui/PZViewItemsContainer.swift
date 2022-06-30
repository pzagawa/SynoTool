//
//  PZViewItemsContainer.swift
//  SynoTool
//
//  Created by Piotr on 06/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZViewItemsContainer<Object, ViewItem: NSView>
{
    private weak var viewItemsContainer: NSView!
    private weak var viewItemsHeightConstraint: NSLayoutConstraint!

    private var itemsObjects: [Object] = []
    
    private var viewItemWidth: CGFloat = 0
    private var viewItemHeight: CGFloat = 0
    
    var viewItemsCount: Int
    {
        return self.viewItemsContainer.subviews.count
    }
    
    var viewItemsTotalHeight: CGFloat
    {
        return (CGFloat(self.viewItemsCount) * self.viewItemHeight)
    }
    
    init()
    {
    }
    
    deinit
    {
        self.reset()
        
        itemsObjects = []
    }
    
    func loadView(owner: Any) -> ViewItem?
    {
        preconditionFailure("This method must be overridden")
    }

    func set(container: NSView, heightConstraint: NSLayoutConstraint)
    {
        self.viewItemsContainer = container
        self.viewItemsHeightConstraint = heightConstraint

        self.viewItemWidth = self.viewItemsContainer.frame.width

        if let viewItem = self.loadView(owner: self.viewItemsContainer)
        {
            self.viewItemHeight = viewItem.bounds.height
        }

        self.reset()
    }
    
    func reset()
    {
        self.viewItemsHeightConstraint.constant = 0

        self.viewItemsContainer.subviews.removeAll()
    }
    
    func set(itemsObjects: [Object])
    {
        synchronized(self)
        {
            let newHeight = CGFloat(itemsObjects.count) * self.viewItemHeight
            
            self.setHeight(height: newHeight)

            let diffItemsObjectsCount = itemsObjects.count - self.itemsObjects.count

            //set new volume objects
            self.itemsObjects = itemsObjects
            
            if (diffItemsObjectsCount == 0)
            {
                //no view items changes
            }
            
            if (diffItemsObjectsCount > 0)
            {
                addViewItems(count: diffItemsObjectsCount)
            }

            if (diffItemsObjectsCount < 0)
            {
                removeViewItems(count: abs(diffItemsObjectsCount))
            }
            
            repositionViewItems()

            updateViewItems(itemsObjects: itemsObjects)
        }
    }

    private func setHeight(height: CGFloat)
    {
        print("[PZViewItemsContainer] setHeight: \(height) old: \(self.viewItemsHeightConstraint.constant)")

        self.viewItemsHeightConstraint.constant = height
        
        self.viewItemsContainer.layoutSubtreeIfNeeded()
    }
    
    private func addViewItems(count: Int)
    {
        print("[PZViewItemsContainer] addViewItems: \(count)")

        for _ in 1...count
        {
            if let viewItem = self.loadView(owner: self.viewItemsContainer)
            {
                self.viewItemsContainer.addSubview(viewItem)
            }
        }
        
    }

    private func removeViewItems(count: Int)
    {
        print("[PZViewItemsContainer] removeViewItems: \(count)")
        
        for _ in 1...count
        {
            if (self.viewItemsContainer.subviews.count > 0)
            {
                let viewItem = self.viewItemsContainer.subviews[0]
                
                viewItem.removeFromSuperview()
            }
        }
    }
    
    private func repositionViewItems()
    {
        var itemPosY: CGFloat = 0
        
        for viewItem: NSView in self.viewItemsContainer.subviews
        {
            viewItem.frame = NSRect(x: 0, y: itemPosY, width: self.viewItemWidth, height: self.viewItemHeight)
            
            viewItem.isHidden = false
            
            itemPosY += self.viewItemHeight
        }

        self.viewItemsContainer.layoutSubtreeIfNeeded()
    }
    
    private func updateViewItems(itemsObjects: [Object])
    {
        for (index, viewItem) in self.viewItemsContainer.subviews.enumerated()
        {
            let objectViewItem = viewItem as! ViewItem

            if (index < itemsObjects.count)
            {
                let itemObject = itemsObjects[index]
                
                self.update(viewItem: objectViewItem, itemObject: itemObject)
            }
        }
    }

    func update(viewItem: ViewItem, itemObject: Object)
    {
        preconditionFailure("This method must be overridden")
    }
    
}
