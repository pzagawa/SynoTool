//
//  PZDownloadsItemsContainer.swift
//  SynoTool
//
//  Created by Piotr on 09/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZDownloadsItemsContainer: PZViewItemsContainer<PZSynoDownloadStationTaskListObject.TaskObject, PZDownloadItem>
{
    typealias OnResumeDownloadItemClickBlock = (_ taskObject: PZSynoDownloadStationTaskListObject.TaskObject) -> Void
    typealias OnPauseDownloadItemClickBlock = (_ taskObject: PZSynoDownloadStationTaskListObject.TaskObject) -> Void
    typealias OnDeleteDownloadItemClickBlock = (_ taskObject: PZSynoDownloadStationTaskListObject.TaskObject) -> Void
    
    var onResumeDownloadItemClickBlock: OnResumeDownloadItemClickBlock? = nil
    var onPauseDownloadItemClickBlock: OnResumeDownloadItemClickBlock? = nil
    var onDeleteDownloadItemClickBlock: OnDeleteDownloadItemClickBlock? = nil

    override func loadView(owner: Any) -> PZDownloadItem?
    {
        return PZDownloadItem.load(owner)
    }

    override func update(viewItem: PZDownloadItem, itemObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        let statusColor = itemObject.taskStatusColor;
        let buttonStateRawValue = itemObject.downloadResumeButtonState.rawValue

        viewItem.itemTitle = itemObject.taskTitle
        viewItem.itemStatus = itemObject.taskStatusText
        viewItem.itemType = itemObject.tastTypeText
        viewItem.fileSize = itemObject.totalSize
        viewItem.fileSizeCompleted = itemObject.downloadedSize

        viewItem.isResumeButtonEnabled = true;
        viewItem.isDeleteButtonEnabled = true;

        viewItem.resumeClick =
        {
            [weak self] (sender) in
            
            if let this = self
            {
                viewItem.isResumeButtonEnabled = false;
                
                let buttonState = itemObject.downloadResumeButtonState
                
                if (buttonState == PZDownloadResumeButton.State.resume)
                {
                    this.onResumeClick(taskObject: itemObject)
                }
                if (buttonState == PZDownloadResumeButton.State.pause)
                {
                    this.onPauseClick(taskObject: itemObject)
                }
            }
        }

        viewItem.deleteClick =
        {
            [weak self] (sender) in
            
            if let this = self
            {
                viewItem.isDeleteButtonEnabled = false;

                this.onDeleteClick(taskObject: itemObject)
            }
        }

        DispatchQueue.main.async
        {
            viewItem.barColor = statusColor
            viewItem.statusColor = statusColor
            viewItem.buttonState = buttonStateRawValue
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25)
        {
            viewItem.updateCompletedPercent()
        }
    }
    
    private func onResumeClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        if let clickBlock = self.onResumeDownloadItemClickBlock
        {
            print("[PZDownloadsItemsContainer] onResumeClick taskObject: \(taskObject.description)")
            
            clickBlock(taskObject)
        }
    }

    private func onPauseClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        if let clickBlock = self.onPauseDownloadItemClickBlock
        {
            print("[PZDownloadsItemsContainer] onPauseClick taskObject: \(taskObject.description)")
            
            clickBlock(taskObject)
        }
    }

    private func onDeleteClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        if let clickBlock = self.onDeleteDownloadItemClickBlock
        {
            print("[PZDownloadsItemsContainer] onDeleteClick taskObject: \(taskObject.description)")

            clickBlock(taskObject)
        }
    }

}
