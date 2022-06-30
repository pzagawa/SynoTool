//
//  PZAddDownloadViewController.swift
//  SynoTool
//
//  Created by Piotr on 23/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZAddDownloadViewController: NSViewController, NSTextFieldDelegate
{
    typealias OnCloseBlock = () -> Void
    
    @IBOutlet weak var appTitleLabel: NSTextField!
    
    @IBOutlet weak var urlEdit: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var addDownloadButton: NSButton!
    
    var device: PZSynoDevice?
    var onCloseBlock: OnCloseBlock?
    
    var urlText: String
    {
        return urlEdit.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var isUrlTextEntered: Bool
    {
        return (self.urlText.isEmpty == false)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateUiState()
    }
    
    override func viewWillAppear()
    {
        if let deviceName = self.device?.deviceName
        {
            self.appTitleLabel.stringValue = deviceName
        }

        super.viewWillAppear()
    }

    @IBAction func onPasteClick(_ sender: Any)
    {
        if let string = NSPasteboard.general().string(forType: NSPasteboardTypeString)
        {
            urlEdit.stringValue = string.trimmingCharacters(in: CharacterSet.whitespaces)

            updateUiState()
        }
    }
    
    @IBAction func onUrlTextUpdate(_ sender: Any)
    {
        updateUiState()
    }

    override func controlTextDidChange(_ obj: Notification)
    {
        if let editField = obj.object as? NSTextField
        {
            if editField == self.urlEdit
            {
                updateUiState()
            }
        }
    }

    private func updateUiState()
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                this.addDownloadButton.isEnabled = this.isUrlTextEntered
            }
        }
    }
    
    @IBAction func onCancelClick(_ sender: Any)
    {
        if let block = self.onCloseBlock
        {
            block()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let viewController = segue.destinationController as? PZAddDownloadExecuteViewController
        {
            viewController.device = self.device
            viewController.url = self.urlText
            viewController.completionBlock =
            {
                [weak self] (isSuccess: Bool) in
                
                if let block = self?.onCloseBlock
                {
                    block()
                }
            }
        }
    }

}
