//
//  PZVolumesItemsContainer.swift
//  SynoTool
//
//  Created by Piotr on 06/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

import Cocoa

class PZVolumesItemsContainer: PZViewItemsContainer<PZSynoSystemStorageInfoObject.Volume, PZStorageVolumeItem>
{
    override func loadView(owner: Any) -> PZStorageVolumeItem?
    {
        return PZStorageVolumeItem.load(owner)
    }
    
    override func update(viewItem: PZStorageVolumeItem, itemObject: PZSynoSystemStorageInfoObject.Volume)
    {
        viewItem.volumeName = itemObject.volumeTitle
        viewItem.volumeStatus = itemObject.volumeStatus
        viewItem.volumeTotalSize = itemObject.totalSize
        viewItem.volumeUsedSize = itemObject.usedSize
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5)
        {
            viewItem.updateUsedPercent()
        }
    }
    
}
