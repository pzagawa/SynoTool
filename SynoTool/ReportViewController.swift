//
//  ReportViewController.swift
//  SynoTool
//
//  Created by Piotr on 18.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class ReportViewController: NSViewController
{
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var systemSectionView: NSView!
    @IBOutlet weak var volumesSectionView: NSView!
    @IBOutlet weak var connectionsSectionView: NSView!
    @IBOutlet weak var downloadsSectionView: NSView!
    
    @IBOutlet weak var systemSectionHeaderLabel: NSTextField!
    @IBOutlet weak var volumesSectionHeaderLabel: NSTextField!
    @IBOutlet weak var connectionSectionHeaderLabel: NSTextField!
    @IBOutlet weak var downloadsSectionHeaderLabel: NSTextField!
    
    @IBOutlet weak var settingsButton: PZSettingsButton!
    @IBOutlet weak var labHostName: NSTextField!
    @IBOutlet weak var headerSeparatorLine: PZSeparatorLine!
    
    @IBOutlet weak var systemAdminLabel: NSTextField!
    @IBOutlet weak var systemModelLabel: NSTextField!
    @IBOutlet weak var systemCPULabel: NSTextField!
    @IBOutlet weak var systemOSLabel: NSTextField!
    @IBOutlet weak var systemOSUpgradeLabel: NSTextField!
    @IBOutlet weak var systemUpTimeTitleLabel: NSTextField!
    @IBOutlet weak var systemUpTimeLabel: NSTextField!
    @IBOutlet weak var systemTempTitleLabel: NSTextField!
    @IBOutlet weak var systemTempLabel: NSTextField!
    @IBOutlet weak var systemUSBDevTitleLabel: NSTextField!
    @IBOutlet weak var systemUSBDevLabel: NSTextField!
    @IBOutlet weak var systemStatusTitleLabel: NSTextField!
    @IBOutlet weak var systemSystemStatusOK: PZTagColorLabel!
    @IBOutlet weak var systemSystemDiskOK: PZTagColorLabel!
    @IBOutlet weak var systemCPULoadLabel: NSTextField!
    @IBOutlet weak var systemSystemLoad: PZProgressBar!
    @IBOutlet weak var systemUserLoad: PZProgressBar!
    @IBOutlet weak var systemIoLoad: PZProgressBar!
    
    @IBOutlet weak var systemUserLoadTitleLabel: NSTextField!
    @IBOutlet weak var systemUserLoadLabel: NSTextField!
    
    @IBOutlet weak var systemSystemLoadTitleLabel: NSTextField!
    @IBOutlet weak var systemSystemLoadLabel: NSTextField!
    
    @IBOutlet weak var systemIoLoadTitleLabel: NSTextField!
    @IBOutlet weak var systemIoLoadLabel: NSTextField!
    
    @IBOutlet weak var storageVolumeItems: NSView!
    @IBOutlet weak var storageVolumeItemsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var connectionsItems: NSView!
    @IBOutlet weak var connectionsItemsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var downloadsItems: NSView!
    @IBOutlet weak var downloadsItemsHeight: NSLayoutConstraint!

    @IBOutlet weak var downloadsInProgressLabel: PZTagColorLabel!
    @IBOutlet weak var downloadsAllLabel: PZTagColorLabel!
    @IBOutlet weak var addDownloadButton: PZAddDownloadButton!
    
    @IBOutlet weak var connectionsLabel: PZTagColorLabel!
    @IBOutlet weak var volumesLabel: PZTagColorLabel!

    weak var popoverAction: PZReportPopoverAction?

    private weak var device: PZSynoDevice?
    
    private var appEventObserver: PZAppEventObserver!
    
    private let volumesItemsContainer: PZVolumesItemsContainer = PZVolumesItemsContainer()
    private let connectionsItemsContainer: PZConnectionsItemsContainer = PZConnectionsItemsContainer()
    private let downloadsItemsContainer: PZDownloadsItemsContainer = PZDownloadsItemsContainer()

    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        self.device = PZSynoApp.sharedInstance.selectedDevice

        self.appEventObserver = PZAppEventObserver()

        self.setupAppEventsObservers()
        
        self.setupSettingsButton()
        
        self.connectionsItemsContainer.onKickConnectionClickBlock =
        {
            [weak self] (connection: PZSynoConnectionsInfoObject.Connection) in

            self?.onKickConnectionClick(connection: connection)
        }
        
        self.downloadsItemsContainer.onResumeDownloadItemClickBlock =
        {
            [weak self] (taskObject: PZSynoDownloadStationTaskListObject.TaskObject) in
            
            self?.onResumeDownloadItemClick(taskObject: taskObject)
        }

        self.downloadsItemsContainer.onPauseDownloadItemClickBlock =
        {
            [weak self] (taskObject: PZSynoDownloadStationTaskListObject.TaskObject) in
            
            self?.onPauseDownloadItemClick(taskObject: taskObject)
        }

        self.downloadsItemsContainer.onDeleteDownloadItemClickBlock =
        {
            [weak self] (taskObject: PZSynoDownloadStationTaskListObject.TaskObject) in
            
            self?.onDeleteDownloadItemClick(taskObject: taskObject)
        }

        self.addDownloadButton.onClickBlock =
        {
            [weak self] (sender) in
            
            self?.onAddDownloadClick()
        }
    }
    
    private func setupAppEventsObservers()
    {
        self.appEventObserver.modelObjectUpdatedEvent
        {
            [weak self] (deviceUID, objectType) in
            
            if let this = self, let device = this.device
            {
                if (device.deviceUID == deviceUID)
                {
                    this.updateSection(objectType: objectType!)
                    this.headerSeparatorLine.isError = (device.model.isLoggedIn == false)
                }
            }
        }
        
        self.appEventObserver.modelObjectRequestStartedEvent
        {
            [weak self] (deviceUID, objectType) in
            
            if let this = self, let device = this.device
            {
                if (device.deviceUID == deviceUID)
                {
                    this.headerSeparatorLine.tick()
                }
            }
        }
        
        self.appEventObserver.modelObjectRequestCompletedEvent
        {
            [weak self] (deviceUID, objectType) in

            if let this = self, let device = this.device
            {
                if (device.deviceUID == deviceUID)
                {
                }
            }
        }
        
        self.appEventObserver.deviceAuthDataChanged
        {
            [weak self] (deviceUID, deviceNumber, isAuthDataSet) in
            
            if let this = self, let device = this.device
            {
                if (device.deviceUID == deviceUID)
                {
                    if isAuthDataSet == false
                    {
                        this.resetUi()
                    }
                }
            }
        }
    }
    
    private func setupSettingsButton()
    {
        self.settingsButton.onClickBlock =
        {
            [weak self] (sender) in
            
            if let action = self?.popoverAction
            {
                action.closePopover()
            }
            
            MainWindowController.showApp()
        }
    }
    
    override var representedObject: Any?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear()
    {
        updateThemeColors()
        
        self.volumesItemsContainer.set(container: self.storageVolumeItems, heightConstraint: self.storageVolumeItemsHeight)
        self.connectionsItemsContainer.set(container: self.connectionsItems, heightConstraint: self.connectionsItemsHeight)
        self.downloadsItemsContainer.set(container: self.downloadsItems, heightConstraint: self.downloadsItemsHeight)
        
        self.systemSystemLoad.maxValue = 100
        self.systemUserLoad.maxValue = 100
        self.systemIoLoad.maxValue = 100
        
        self.initTagLabel(volumesLabel)
        self.initTagLabel(connectionsLabel)
        self.initTagLabel(downloadsInProgressLabel)
        self.initTagLabel(downloadsAllLabel)

        self.updateHeader()
        
        self.backgroundView.layoutSubtreeIfNeeded()
    }

    private func updateHeader()
    {
        if let device = self.device
        {
            if let deviceName = device.deviceName
            {
                self.labHostName.stringValue = deviceName
            }
            else
            {
                self.labHostName.stringValue = ""
            }
            
            self.headerSeparatorLine.isError = (device.model.isLoggedIn == false)
        }
        else
        {
            self.labHostName.stringValue = ""

            self.headerSeparatorLine.isError = true
        }
    }
    
    private func updateThemeColors()
    {
        PZTheme.updateDarkMode()

        self.labHostName.textColor = NSColor.labelColor
        
        self.clipView.backgroundColor = PZTheme.backgroundColor
        
        self.systemAdminLabel.textColor = PZTheme.systemAdminTextColor

        self.systemSectionHeaderLabel.textColor = PZTheme.sectionHeaderTextColor
        self.volumesSectionHeaderLabel.textColor = PZTheme.sectionHeaderTextColor
        self.connectionSectionHeaderLabel.textColor = PZTheme.sectionHeaderTextColor
        self.downloadsSectionHeaderLabel.textColor = PZTheme.sectionHeaderTextColor

        self.systemModelLabel.textColor = PZTheme.sectionTextColor
        self.systemCPULabel.textColor = PZTheme.sectionTextColor
        self.systemOSLabel.textColor = PZTheme.sectionTextColor
        
        self.systemOSUpgradeLabel.textColor = PZTheme.systemOSUpgradeTextColor

        self.systemUpTimeTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemUpTimeLabel.textColor = PZTheme.sectionValueColor
        
        self.systemTempTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemTempLabel.textColor = PZTheme.sectionValueColor
        
        self.systemUSBDevTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemUSBDevLabel.textColor = PZTheme.sectionValueColor

        self.systemStatusTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemCPULoadLabel.textColor = PZTheme.sectionTextColor

        self.systemSystemStatusOK.normalBkgColor = PZTheme.systemSystemStatusTagNormalColor
        self.systemSystemStatusOK.errorBkgColor = PZTheme.systemSystemStatusTagErrorColor
        self.systemSystemStatusOK.nullBkgColor = PZTheme.systemSystemStatusTagNullColor

        self.systemSystemDiskOK.normalBkgColor = PZTheme.systemSystemStatusTagNormalColor
        self.systemSystemDiskOK.errorBkgColor = PZTheme.systemSystemStatusTagErrorColor
        self.systemSystemDiskOK.nullBkgColor = PZTheme.systemSystemStatusTagNullColor

        self.systemUserLoadTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemUserLoadLabel.textColor = PZTheme.sectionValueColor

        self.systemSystemLoadTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemSystemLoadLabel.textColor = PZTheme.sectionValueColor

        self.systemIoLoadTitleLabel.textColor = PZTheme.sectionTextColor
        self.systemIoLoadLabel.textColor = PZTheme.sectionValueColor

        self.systemUserLoad.bkgColor = PZTheme.defaultBarBkgColor
        self.systemSystemLoad.bkgColor = PZTheme.defaultBarBkgColor
        self.systemIoLoad.bkgColor = PZTheme.defaultBarBkgColor

        self.systemUserLoad.barColor050 = PZTheme.defaultBar050Color
        self.systemUserLoad.barColor075 = PZTheme.defaultBar075Color
        self.systemUserLoad.barColor100 = PZTheme.defaultBar100Color

        self.systemSystemLoad.barColor050 = PZTheme.defaultBar050Color
        self.systemSystemLoad.barColor075 = PZTheme.defaultBar075Color
        self.systemSystemLoad.barColor100 = PZTheme.defaultBar100Color

        self.systemIoLoad.barColor050 = PZTheme.defaultBar050Color
        self.systemIoLoad.barColor075 = PZTheme.defaultBar075Color
        self.systemIoLoad.barColor100 = PZTheme.defaultBar100Color

        self.volumesLabel.normalBkgColor = PZTheme.valueTagNormalColor
        self.connectionsLabel.normalBkgColor = PZTheme.valueTagNormalColor
        self.downloadsInProgressLabel.normalBkgColor = PZTheme.valueProgressTagColor
        self.downloadsAllLabel.normalBkgColor = PZTheme.valueCompletedTagColor
        
        self.addDownloadButton.defaultBackgroundColor = PZTheme.buttonBackgroundColor
        self.addDownloadButton.defaultSymbolColor = PZTheme.buttonSymbolColor
        self.addDownloadButton.disabledSymbolColor = PZTheme.buttonDisabledSymbolColor

    }
    
    override func viewDidAppear()
    {
        self.updateSection(objectType: PZSynoModel.ObjectType.fileStationInfo)
        self.updateSection(objectType: PZSynoModel.ObjectType.systemInfo)
        self.updateSection(objectType: PZSynoModel.ObjectType.systemStatus)
        self.updateSection(objectType: PZSynoModel.ObjectType.cpuLoadInfo)
        self.updateSection(objectType: PZSynoModel.ObjectType.systemStorageInfo)
        self.updateSection(objectType: PZSynoModel.ObjectType.connectionsInfo)
        self.updateSection(objectType: PZSynoModel.ObjectType.downloadStationTaskList)
        
        if let device = self.device
        {
            device.model.enableUpdateDataTimer()
        }
    }

    private func resetUi()
    {
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoFileStationInfoObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemInfoObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemStatusObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoCpuLoadInfoObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemStorageInfoObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoConnectionsInfoObject>())
        updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoDownloadStationTaskListObject>())
    }
    
    private func initTagLabel(_ label: PZTagColorLabel)
    {
        label.stringValue = ""
        label.isHidden = true
        label.isError = false
    }

    override func viewWillDisappear()
    {
        if let device = self.device
        {
            device.model.disableUpdateDataTimer()
        }
    }
    
    private func updateWithObject<T: PZSynoObject>(synoResponseObject: PZSynoResponseObject<T>?, completion: @escaping (_ : ReportViewController, _ : T) -> Void)
    {
        if let responseObject = synoResponseObject
        {
            if let object = responseObject.value
            {
                DispatchQueue.main.async
                {
                    [weak self] in
                    
                    if let this = self
                    {
                        synchronized(this)
                        {
                            completion(this, object)
                        }
                    }
                }
            }
        }
    }
    
    private func updateSection(objectType: PZSynoModel.ObjectType)
    {
        guard let device = self.device else
        {
            return
        }
        
        if device.isAuthDataSet == false
        {
            return
        }

        if (objectType == PZSynoModel.ObjectType.fileStationInfo)
        {
            updateSectionWithObject(synoResponseObject: device.model.fileStationInfoObject)
        }
        
        if (objectType == PZSynoModel.ObjectType.systemInfo)
        {
            updateSectionWithObject(synoResponseObject: device.model.systemInfoObject)
        }
        
        if (objectType == PZSynoModel.ObjectType.systemStatus)
        {
            updateSectionWithObject(synoResponseObject: device.model.systemStatusObject)
        }

        if (objectType == PZSynoModel.ObjectType.cpuLoadInfo)
        {
            updateSectionWithObject(synoResponseObject: device.model.cpuLoadInfoObject)
        }

        if (objectType == PZSynoModel.ObjectType.systemStorageInfo)
        {
            updateSectionWithObject(synoResponseObject: device.model.systemStorageInfoObject)
        }

        if (objectType == PZSynoModel.ObjectType.connectionsInfo)
        {
            updateSectionWithObject(synoResponseObject: device.model.connectionsInfoObject)
        }

        if (objectType == PZSynoModel.ObjectType.downloadStationTaskList)
        {
            updateSectionWithObject(synoResponseObject: device.model.downloadStationTaskListObject)
        }
    }
    
    //UI SECTION WITH OBJECT: PZSynoFileStationInfoObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoFileStationInfoObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.labHostName.animator().stringValue = object.hostNameText
            this.systemAdminLabel.animator().isHidden = (object.isManager == false)
        })
    }

    //UI SECTION WITH OBJECT: PZSynoSystemInfoObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemInfoObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.systemModelLabel.animator().stringValue = object.modelInfoText
            this.systemCPULabel.animator().stringValue = object.cpuInfoText
            this.systemOSLabel.animator().stringValue = object.osInfoText
            this.systemUpTimeLabel.animator().stringValue = object.upTimeInfoText
            this.systemTempLabel.animator().stringValue = object.sysTempInfoText
            this.systemUSBDevLabel.animator().stringValue = object.usbDevicesInfoText
        })
    }
    
    //UI SECTION WITH OBJECT: PZSynoSystemStatusObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemStatusObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.systemOSUpgradeLabel.animator().isHidden = (object.isUpgradeReady == false);
            this.systemSystemStatusOK.animator().stringValue = object.systemStatusText
            this.systemSystemDiskOK.animator().stringValue = object.diskStatusText
            
            this.systemSystemStatusOK.isError = object.isStatusSet ? (object.isSystemOK == false) : nil
            this.systemSystemDiskOK.isError = object.isStatusSet ? (object.isDiskOK == false) : nil
        })
    }

    //UI SECTION WITH OBJECT: PZSynoCpuLoadInfoObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoCpuLoadInfoObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.systemSystemLoad.value = object.systemLoad
            this.systemUserLoad.value = object.userLoad
            this.systemIoLoad.value = object.ioLoad
            
            this.systemUserLoadLabel.animator().stringValue = object.userLoadText
            this.systemSystemLoadLabel.animator().stringValue = object.systemLoadText
            this.systemIoLoadLabel.animator().stringValue = object.ioLoadText
        })
    }
    
    //UI SECTION WITH OBJECT: PZSynoSystemStorageInfoObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoSystemStorageInfoObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.volumesLabel.stringValue = String(object.countVolumes)
            self.volumesLabel.isHidden = false
            
            this.volumesItemsContainer.set(itemsObjects: object.volumeList)
            
            this.updateBackgroundViewHeight()
        })
    }
    
    //UI SECTION WITH OBJECT: PZSynoConnectionsInfoObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoConnectionsInfoObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.connectionsLabel.stringValue = String(object.countConnections)
            self.connectionsLabel.isHidden = false
            
            this.connectionsItemsContainer.set(itemsObjects: object.connectionList)
            
            this.updateBackgroundViewHeight()
        })
    }
    
    //UI SECTION WITH OBJECT: PZSynoDownloadStationTaskListObject
    private func updateSectionWithObject(synoResponseObject: PZSynoResponseObject<PZSynoDownloadStationTaskListObject>?)
    {
        updateWithObject(synoResponseObject: synoResponseObject, completion:
        {
            (this, object) in
            
            this.downloadsInProgressLabel.stringValue = String(object.countInProgressTaskObjects)
            self.downloadsInProgressLabel.isHidden = false
            
            this.downloadsAllLabel.stringValue = String(object.countCompletedTaskObjects)
            self.downloadsAllLabel.isHidden = false
            
            this.downloadsItemsContainer.set(itemsObjects: object.taskObjectList)
            
            this.updateBackgroundViewHeight()
        })
    }
    
    //UI LAYOUT
    private func totalSectionsHeight() -> CGFloat
    {
        var height: CGFloat = 0;
        
        height += self.systemSectionView.frame.height
        height += self.volumesSectionView.frame.height
        height += self.connectionsSectionView.frame.height
        height += self.downloadsSectionView.frame.height
        
        if (height < self.scrollView.frame.height)
        {
            height = self.scrollView.frame.height
        }
        
        return height
    }
    
    private func updateBackgroundViewHeight()
    {
        DispatchQueue.global().async
        {
            DispatchQueue.main.async
            {
                [weak self] in
                
                if let this = self
                {
                    let height = this.totalSectionsHeight()
                    
                    if (this.backgroundViewHeight.constant != height)
                    {
                        this.backgroundViewHeight.constant = height
                        
                        if let documentView = this.scrollView.documentView
                        {
                            documentView.frame = NSRect(x: 0, y: 0, width: documentView.frame.width, height: height)
                        }
                    }
                    
                    this.view.layoutSubtreeIfNeeded()
                }
            }
        }
    }

    private func onKickConnectionClick(connection: PZSynoConnectionsInfoObject.Connection)
    {
        if let device = self.device
        {
            device.model.API_connectionKick(device: device, connection: connection)
            {
                (responseObject: PZSynoResponseObject<PZSynoEmptyObject>) in
                
                print("[ReportViewController] onKickConnectionClick: \(connection.requestKey) response: \(responseObject.statusText)")
            }
        }
    }

    private func downloadStationTaskControl(taskObject: PZSynoDownloadStationTaskListObject.TaskObject, controlType: PZSynoAPI.TaskControlType)
    {
        if let device = self.device
        {
            let taskId = taskObject.taskId
            
            device.model.API_downloadStationTaskControl(device: device, controlType: controlType, taskId: taskId)
            {
                (responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskControlObject>) in
                
                if responseObject.isSuccess
                {
                    device.model.downloadStationTaskListObject?.invalidate()
                }
                
                print("[ReportViewController] downloadStationTaskControl: [\(controlType)]. \(taskObject.description) response: \(responseObject.statusText)")
            }
        }
    }

    private func onResumeDownloadItemClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        let controlType = PZSynoAPI.TaskControlType.Resume
        
        downloadStationTaskControl(taskObject: taskObject, controlType: controlType)
    }

    private func onPauseDownloadItemClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        let controlType = PZSynoAPI.TaskControlType.Pause
        
        downloadStationTaskControl(taskObject: taskObject, controlType: controlType)
    }

    private func onDeleteDownloadItemClick(taskObject: PZSynoDownloadStationTaskListObject.TaskObject)
    {
        let controlType = PZSynoAPI.TaskControlType.Delete
        
        downloadStationTaskControl(taskObject: taskObject, controlType: controlType)
    }

    private func onAddDownloadClick()
    {
        print("[ReportViewController] onAddDownloadClick")

        if let device = self.device
        {
            if device.model.isLoggedIn == false
            {
                let text = "Application is not logged in"
                
                AppDelegate.instance.showError(text: text)
                
                return
            }

            if device.model.isDownloadStationAccessible == false
            {
                let text = "Download Station on NAS device is not installed"
                
                AppDelegate.instance.showError(text: text)
                
                return
            }
            
            if let action = self.popoverAction
            {
                action.closePopover()
            }

            AppDelegate.instance.showAddDownloadWith(device: device)
        }
    }

}

