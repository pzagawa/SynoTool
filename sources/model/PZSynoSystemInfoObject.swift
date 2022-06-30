//
//  PZSynoSystemInfoObject.swift
//  testSynoMount
//
//  Created by Piotr on 31.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoSystemInfoObject: PZSynoObject
{
    private var cpu_clock_speed: Int?
    private var cpu_cores: String?
    private var cpu_family: String?
    private var cpu_series: String?
    private var cpu_vendor: String?
    
    private var firmware_ver: String?
    private var firmware_date: String?
    
    private var model: String?
    private var ram_size: Int?
    private var serial: String?
    private var sys_temp: Int?

    private var time: String?
    private var time_zone: String?
    private var time_zone_desc: String?
    
    private var up_time: String?
    private var usb_dev: [String]?
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.cpu_clock_speed = dataObject["cpu_clock_speed"] as? Int
        self.cpu_cores = dataObject["cpu_cores"] as? String
        self.cpu_family = dataObject["cpu_family"] as? String
        self.cpu_series = dataObject["cpu_series"] as? String
        self.cpu_vendor = dataObject["cpu_vendor"] as? String
        
        self.firmware_ver = dataObject["firmware_ver"] as? String
        self.firmware_date = dataObject["firmware_date"] as? String
        
        self.model = dataObject["model"] as? String
        self.ram_size = dataObject["ram_size"] as? Int
        self.serial = dataObject["serial"] as? String
        self.sys_temp = dataObject["sys_temp"] as? Int
        
        self.time = dataObject["time"] as? String
        self.time_zone = dataObject["time_zone"] as? String
        self.time_zone_desc = dataObject["time_zone_desc"] as? String

        self.up_time = dataObject["up_time"] as? String
        self.usb_dev = dataObject["usb_dev"] as? [String]
    }

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    //FORMAT:
    //MARVELL Armada 370 88F6707 1 * 800 Mhz
    //
    var cpuInfoText: String
    {
        if self.cpu_vendor == nil && self.cpu_family == nil && self.cpu_series == nil
        {
            return ""
        }
        
        let cpu_clock_speed: String = self.cpu_clock_speed == nil ? "" : String(self.cpu_clock_speed!)
        let cpu_cores: String = self.cpu_cores == nil ? "" : self.cpu_cores!
        let cpu_family: String = self.cpu_family == nil ? "" : self.cpu_family!
        let cpu_series: String = self.cpu_series == nil ? "" : self.cpu_series!
        let cpu_vendor: String = self.cpu_vendor == nil ? "" : self.cpu_vendor!

        return "\(cpu_vendor) \(cpu_family) \(cpu_series) \(cpu_cores) * \(cpu_clock_speed) Mhz"
    }
    
    //FORMAT:
    //DSM 6.0.2-8451 Update 1. 2016/09/01
    //
    var osInfoText: String
    {
        if self.firmware_ver == nil && self.firmware_date == nil
        {
            return ""
        }
            
        let firmware_ver: String = self.firmware_ver == nil ? "<null>" : self.firmware_ver!
        let firmware_date: String = self.firmware_date == nil ? "<null>" : self.firmware_date!
        
        return "\(firmware_ver). \(firmware_date)"
    }
    
    var usbDevicesInfoText: String
    {
        if self.usb_dev == nil
        {
            return ""
        }
        
        var list: String = "NONE"
        
        if let usbDevList = self.usb_dev
        {
            if usbDevList.count > 0
            {
                for usbDevice: String in usbDevList
                {
                    list += "\(usbDevice) "
                }
            }
        }
        
        return list
    }
    
    var usbDevicesCount: Int
    {
        if let usbDevList = self.usb_dev
        {
            return usbDevList.count
        }
        
        return 0
    }

    var usbDevicesCountText: String
    {
        if let usbDevList = self.usb_dev
        {
            if usbDevList.count > 0
            {
                return "\(usbDevList.count)"
            }
        }
        
        return "NONE"
    }

    //FORMAT:
    //DS115j 256 MB SN:1620MNN475503
    //
    var modelInfoText: String
    {
        if self.model == nil && self.ram_size == nil && self.serial == nil
        {
            return ""
        }

        let model: String = self.model == nil ? "" : self.model!
        let ram_size: String = self.ram_size == nil ? "" : String(self.ram_size!)
        let serial: String = self.serial == nil ? "" : self.serial!

        return "\(model) \(ram_size) MB SN:\(serial)"
    }
    
    var sysTempInfoText: String
    {
        if (self.sys_temp == nil)
        {
            return ""
        }
        
        let sys_temp: String = self.sys_temp == nil ? "" : String(self.sys_temp!)
        
        return "\(sys_temp)"
    }
    
    var timeInfoText: String
    {
        let time: String = self.time == nil ? "" : self.time!
        let time_zone: String = self.time_zone == nil ? "" : self.time_zone!
        let time_zone_desc: String = self.time_zone_desc == nil ? "" : self.time_zone_desc!
        
        return "\(time) \(time_zone) \(time_zone_desc)"
    }
    
    var upTimeInfoText: String
    {
        if self.up_time == nil
        {
            return ""
        }
        
        let up_time: String = self.up_time == nil ? "" : self.up_time!

        return "\(up_time)"
    }
    
    override var description: String
    {
        var lines = ""
        
        lines += "- model: \(self.modelInfoText)\n"
        lines += "- os: \(self.osInfoText)\n"
        lines += "- cpu: \(self.cpuInfoText)\n"
        lines += "- sys temp: \(self.sysTempInfoText)\n"
        lines += "- time: \(self.upTimeInfoText)\n"
        lines += "- usb devices:\n \(self.usbDevicesInfoText)\n"

        return lines
    }

}
