//
//  PZConnectionsItemsContainer.swift
//  SynoTool
//
//  Created by Piotr on 06/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZConnectionsItemsContainer: PZViewItemsContainer<PZSynoConnectionsInfoObject.Connection, PZConnectionItem>
{
    typealias OnKickConnectionClickBlock = (_ connection: PZSynoConnectionsInfoObject.Connection) -> Void
    
    var onKickConnectionClickBlock: OnKickConnectionClickBlock? = nil
    
    override func loadView(owner: Any) -> PZConnectionItem?
    {
        return PZConnectionItem.load(owner)
    }

    override func update(viewItem: PZConnectionItem, itemObject: PZSynoConnectionsInfoObject.Connection)
    {
        viewItem.connectionWho = itemObject.connectionWho
        viewItem.connectionDescription = itemObject.connectionDescription
        viewItem.connectionType = itemObject.connectionType
        viewItem.connectionFrom = itemObject.connectionFrom
        viewItem.isKickEnabled = itemObject.isKickEnabled
        
        viewItem.kickClick =
        {
            [weak self] (sender) in

            if let this = self
            {
                if let clickBlock = this.onKickConnectionClickBlock
                {
                    print("[PZConnectionsItemsContainer] kickClick connection: \(itemObject.requestKey)")

                    clickBlock(itemObject)
                }
            }
        }
    }
    
}
