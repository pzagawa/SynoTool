//
//  PZAddDownloadExecuteViewController.swift
//  SynoTool
//
//  Created by Piotr on 25/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZAddDownloadExecuteViewController: NSViewController
{
    typealias Completion = (_ isSuccess: Bool) -> Void

    @IBOutlet weak var statusIconInfo: NSImageView!
    @IBOutlet weak var statusIconCaution: NSImageView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var operationProgress: NSProgressIndicator!
    @IBOutlet weak var closeButton: NSButton!
 
    var isSuccess: Bool = false
    
    var device: PZSynoDevice?
    var url: String?
    var completionBlock: Completion?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        
        self.addDownload()
    }
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        
    }

    @IBAction func onCloseButtonClick(_ sender: Any)
    {
        self.closeDialog()
    }

    private func closeDialog()
    {
        self.dismiss(self)
        
        if let block = self.completionBlock
        {
            block(self.isSuccess)
        }
    }
    
    private func setUiProgressState()
    {
        DispatchQueue.main.async
        {
            [weak self] in

            if let this = self
            {
                this.statusIconCaution.isHidden = true
                this.statusIconInfo.isHidden = true

                this.operationProgress.startAnimation(this)
                this.operationProgress.isHidden = false

                this.statusLabel.stringValue = "Waiting for Download Station to add task"

                this.informationLabel.stringValue = ""
                this.informationLabel.isHidden = true

                this.closeButton.isEnabled = false
            }
        }
    }

    private func setUiCompletedState(errorText: String? = nil)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                this.operationProgress.stopAnimation(this)
                this.operationProgress.isHidden = true
                
                if let error = errorText
                {
                    this.statusLabel.stringValue = "Failed to add task"
                    this.informationLabel.stringValue = error
                    this.informationLabel.isHidden = false
                    this.statusIconCaution.isHidden = false
                }
                else
                {
                    this.statusLabel.stringValue = "Task added successfully"
                    this.informationLabel.stringValue = ""
                    this.informationLabel.isHidden = true
                    this.statusIconInfo.isHidden = false
                }
                
                this.closeButton.isEnabled = true
            }
        }
    }
    
    private func addDownload()
    {
        if let device = self.device, let url = self.url
        {
            self.setUiProgressState()
            
            device.model.API_downloadStationTaskCreate(device: device, uri: url, completion:
            {
                [weak self] (responseObject: PZSynoResponseObject<PZSynoEmptyObject>) in
                
                if let this = self
                {
                    if responseObject.isSuccess
                    {
                        this.isSuccess = true
                        
                        device.model.downloadStationTaskListObject?.invalidate()

                        this.setUiCompletedState()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
                        {
                            this.closeDialog()
                        }
                    }
                    else
                    {
                        this.setUiCompletedState(errorText: responseObject.statusText)
                    }
                }
            })
        }
    }

}
