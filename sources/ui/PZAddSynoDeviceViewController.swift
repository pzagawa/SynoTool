//
//  PZAddSynoDeviceViewController.swift
//  SynoTool
//
//  Created by Piotr on 26/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

class PZAddSynoDeviceViewController: NSViewController, NSTextFieldDelegate
{
    @IBOutlet weak var connectionStatusLabel: PZTagColorLabel!
    @IBOutlet weak var hostEdit: NSTextField!
    @IBOutlet weak var userNameEdit: NSTextField!
    @IBOutlet weak var passwordEdit: NSSecureTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var signInButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    
    private let device: PZSynoDevice = PZSynoDevice(deviceNumber: 1000)
    
    private var isHostResponse: Bool = false
    {
        didSet(value)
        {
            updateUiState()
        }
    }

    var hostText: String
    {
        return hostEdit.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var userNameText: String
    {
        return userNameEdit.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var passwordText: String
    {
        return passwordEdit.stringValue
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        connectionStatusLabel.stringValue = ""
        connectionStatusLabel.normalBkgColor = NSColor(calibratedWhite: 0.7, alpha: 1.0)
        connectionStatusLabel.isError = false

        updateUiState()
        
        connectionState = .noConnection
    }

    override func viewWillAppear()
    {
        super.viewWillAppear()
        
    }
    
    private enum ConnectionState
    {
        case noConnection
        case authApiResponse(version: Int)
        case noAuthApiResponse
        case networkError
        case synoError(code: Int)
        case statusCode(code: Int)
        case signedIn
        case signInError
        case keychainSaveError
    }

    private func statusText(connectionState: ConnectionState) -> String
    {
        switch connectionState
        {
        case .noConnection:
            return "status"
        case .authApiResponse(let version):
            return "host auth version \(version)"
        case .noAuthApiResponse:
            return "no host response"
        case .networkError:
            return "can't connect"
        case .synoError(let code):
            return "device status \(code)"
        case .statusCode(let code):
            if code == 0
            {
                return "host url incorrect"
            }
            else
            {
                return "host status code \(code)"
            }
        case .signedIn:
            return "signed in"
        case .signInError:
            return "sign in error"
        case .keychainSaveError:
            return "error saving data to keychain"
        }
    }

    private func statusColor(connectionState: ConnectionState) -> NSColor
    {
        switch connectionState
        {
        case .noConnection:
            return NSColor(calibratedWhite: 0.7, alpha: 1.0)
        case .authApiResponse:
            return NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)
        case .noAuthApiResponse:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .networkError:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .synoError:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .statusCode:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .signedIn:
            return NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.3, alpha: 1.0)
        case .signInError:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .keychainSaveError:
            return NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        }
    }

    private var connectionState: ConnectionState = .noConnection
    {
        didSet
        {
            let state = self.connectionState
            
            DispatchQueue.main.async
            {
                [weak self] in
                
                if let this = self
                {
                    this.connectionStatusLabel.stringValue = this.statusText(connectionState: state).uppercased()
                    this.connectionStatusLabel.normalBkgColor = this.statusColor(connectionState: state)
                }
            }
        }
    }
    
    @IBAction func onHostEditUpdate(_ sender: Any)
    {
        updateUiState()
        
        self.testHostResponse
        {
            [weak self] (connectionState) in
            
            self?.connectionState = connectionState
        }
    }
    
    @IBAction func onUserNameEditUpdate(_ sender: Any)
    {
        updateUiState()
    }
    
    @IBAction func onPasswordEditUpdate(_ sender: Any)
    {
        updateUiState()
    }
    
    override func controlTextDidChange(_ obj: Notification)
    {
        if let editField = obj.object as? NSTextField
        {
            if editField == self.hostEdit
            {
                updateUiState()
            }
            if editField == self.userNameEdit
            {
                updateUiState()
            }
            if editField == self.passwordEdit
            {
                updateUiState()
            }
        }
    }
    
    private var isAuthDataValid: Bool
    {
        if self.isHostResponse == false
        {
            return false
        }
        
        if self.hostText.isEmpty
        {
            return false
        }
        
        if self.userNameText.isEmpty
        {
            return false
        }
        
        if self.passwordText.isEmpty
        {
            return false
        }
        
        return true
    }

    private func updateUiState()
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                this.signInButton.isEnabled = this.isAuthDataValid
            }
        }
    }

    @IBAction func onCancelButtonClick(_ sender: Any)
    {
        self.dismiss(self)
    }
    
    private var isProgressVisible: Bool = false
    {
        didSet
        {
            let visible = self.isProgressVisible

            DispatchQueue.main.async
            {
                [weak self] in
            
                if let this = self
                {
                    this.progressIndicator.isHidden = (visible == false)
                    this.progressLabel.isHidden = (visible == false)
                    
                    if visible
                    {
                        this.progressIndicator.startAnimation(this)
                    }
                    else
                    {
                        this.progressIndicator.stopAnimation(this)
                    }
                }
            }
        }
    }

    private var isUiEnabled: Bool = true
    {
        didSet
        {
            let enabled = self.isUiEnabled
            
            DispatchQueue.main.async
            {
                [weak self] in

                if let this = self
                {
                    this.hostEdit.isEnabled = enabled
                    this.userNameEdit.isEnabled = enabled
                    this.passwordEdit.isEnabled = enabled
                    this.cancelButton.isEnabled = enabled
                    this.signInButton.isEnabled = enabled
                }
            }
        }
    }
    
    @IBAction func onSignInButtonClick(_ sender: Any)
    {
        if self.hostText.isEmpty || self.userNameText.isEmpty || self.passwordText.isEmpty
        {
            return
        }

        self.isProgressVisible = true
        self.isUiEnabled = false
        
        self.device.authData = PZAuthData(host: self.hostText, account: self.userNameText, password: self.passwordText)
        
        self.device.model.signInTestWithCompletion
        {
            [weak self] (isSignInSuccess) in

            if let this = self
            {
                this.isProgressVisible = false

                if isSignInSuccess
                {
                    this.connectionState = .signedIn
                    
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1)
                    {
                        DispatchQueue.main.async
                        {
                            if this.saveAuthData()
                            {
                                this.dismiss(this)
                            }
                            else
                            {
                                this.connectionState = .keychainSaveError
                                this.isUiEnabled = true
                            }
                        }
                    }
                }
                else
                {
                    this.connectionState = .signInError
                    this.isUiEnabled = true
                }
            }
        }
    }
    
    private func testHostResponse(completion: @escaping (_ connectionState: ConnectionState) -> Void)
    {
        self.isHostResponse = false
        
        self.device.model.testHostResponse(host: self.hostText)
        {
            [weak self] (apiInfoStatus: PZSynoAPI.ApiInfoStatus) in

            switch apiInfoStatus
            {
            case .notSet:
                completion(ConnectionState.noConnection)
            case .networkError:
                completion(ConnectionState.networkError)
            case .synoError(let code):
                completion(ConnectionState.synoError(code: code))
            case .statusCode(let code):
                completion(ConnectionState.statusCode(code: code))
            case .infoApiResponse(let version):
                self?.isHostResponse = true
                completion(ConnectionState.authApiResponse(version: version))
            case .noInfoApiResponse:
                completion(ConnectionState.noAuthApiResponse)
            }
        }
    }

    private func saveAuthData() -> Bool
    {
        let device = PZSynoApp.sharedInstance.selectedDevice
        
        let result = device.setAuthData(host: self.hostText, account: self.userNameText, password: self.passwordText)
        
        if result.isSuccess
        {
            return true
        }
        
        return false
    }
    
}
