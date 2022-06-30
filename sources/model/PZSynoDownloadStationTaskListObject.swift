//
//  PZSynoDownloadStationTaskListObject.swift
//  synoToolTest
//
//  Created by Piotr on 12.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoDownloadStationTaskListObject: PZSynoObject
{
    class TaskObject
    {
        enum TaskType: String
        {
            case invalid
            case bt
            case nzb
            case http
            case ftp
            case emule
        }

        enum Status: String
        {
            case invalid
            case waiting
            case downloading
            case paused
            case finishing
            case finished
            case sum_checking
            case seeding
            case filehosting_waiting
            case extracting
            case error
        }

        private var id: String?
        private var type_value: String?
        private var username: String?
        private var title: String?
        private var size: Int?
        private var status_value: String?
        private var status_extra: [String: AnyObject?]?
        
        private var transfer_sizeDownloaded: Int?
        private var transfer_sizeUploaded: Int?
        private var transfer_speedDownload: Int?
        private var transfer_speedUpload: Int?

        init(dataObject: NSDictionary)
        {
            self.id = dataObject["id"] as? String
            self.type_value = dataObject["type"] as? String
            self.username = dataObject["username"] as? String
            self.title = dataObject["title"] as? String
            self.size = dataObject["size"] as? Int
            self.status_value = dataObject["status"] as? String
            self.status_extra = dataObject["status_extra"] as? [String: AnyObject?]
            
            if let additional = dataObject["additional"] as? [String: AnyObject?]
            {
                if let file = additional["transfer"] as? [String: AnyObject?]
                {
                    self.transfer_sizeDownloaded = file["size_downloaded"] as? Int
                    self.transfer_sizeUploaded = file["size_uploaded"] as? Int
                    self.transfer_speedDownload = file["speed_download"] as? Int
                    self.transfer_speedUpload = file["speed_upload"] as? Int
                }
            }
        }
        
        var json: NSDictionary
        {
            let json = NSMutableDictionary()
            
            json["id"] = self.id == nil ? nil : self.id!
            json["type"] = self.type_value == nil ? nil : self.type_value!
            json["username"] = self.username == nil ? nil : self.username!
            json["title"] = self.title == nil ? nil : self.title!
            json["size"] = self.size == nil ? nil : self.size!
            json["status"] = self.status_value == nil ? nil : self.status_value!
            json["status_extra"] = self.status_extra == nil ? nil : self.status_extra!
            
            let transfer = NSDictionary(dictionary:
            [
                "size_downloaded": self.transfer_sizeDownloaded ?? 0,
                "size_uploaded": self.transfer_sizeUploaded ?? 0,
                "speed_download": self.transfer_speedDownload ?? 0,
                "speed_upload": self.transfer_speedUpload ?? 0,
            ])

            json["additional"] = NSDictionary(dictionary: ["transfer": transfer])
            
            return NSDictionary(dictionary: json)
        }

        var errorDetailText: String?
        {
            if let statusExtra = self.status_extra
            {
                let value: AnyObject? = statusExtra["error_detail"]!
                
                return String(describing: value)
            }
            
            return nil
        }
        
        var taskId: String
        {
            if let id = self.id
            {
                return id
            }
            
            return ""
        }
        
        var taskTitle: String
        {
            if let title = self.title
            {
                return title
            }
            
            return ""
        }

        var totalSize: UInt
        {
            if (self.size == nil)
            {
                return 0
            }
            
            return UInt(self.size!)
        }

        var totalSizeFormatted: String
        {
            let formatter = ByteCountFormatter()
            
            let size = self.totalSize
            
            return formatter.string(fromByteCount: Int64(size))
        }
        
        var downloadedSize: UInt
        {
            if (self.transfer_sizeDownloaded == nil)
            {
                return 0
            }
            
            return UInt(self.transfer_sizeDownloaded!)
        }

        var downloadedSizeFormatted: String
        {
            let formatter = ByteCountFormatter()
            
            let size = self.downloadedSize
            
            return formatter.string(fromByteCount: Int64(size))
        }
        
        var taskType: TaskType
        {
            if let type = self.type_value
            {
                if let result = TaskType(rawValue: type.lowercased())
                {
                    return result
                }
            }

            return TaskType.invalid
        }
        
        var tastTypeText: String
        {
            if self.taskType == TaskType.invalid
            {
                return ""
            }
            
            return self.taskType.rawValue
        }
        
        var taskStatus: Status
        {
            if let status = self.status_value
            {
                if let result = Status(rawValue: status.lowercased())
                {
                    return result
                }
            }
            
            return Status.invalid
        }
        
        var taskStatusColor: NSColor
        {
            switch self.taskStatus
            {
            case .waiting: return PZTheme.barStateInactiveColor
            case .downloading: return PZTheme.barStateProgressColor
            case .paused: return PZTheme.barStatePauseColor
            case .finished: return PZTheme.barStateCompletedColor
            case .finishing: return PZTheme.barStateProgressColor
            case .error: return PZTheme.barStateErrorColor
            case .sum_checking: return PZTheme.barStateProgressColor
            case .seeding: return PZTheme.barStateCompletedColor
            case .filehosting_waiting: return PZTheme.barStateInactiveColor
            case .extracting: return PZTheme.barStateProgressColor
            default:
                return PZTheme.barStateInactiveColor
            }
        }
        
        var taskStatusText: String
        {
            switch self.taskStatus
            {
            case .waiting: return "waiting"
            case .downloading: return "downloading"
            case .paused: return "paused"
            case .finishing: return "finishing"
            case .finished: return "finished"
            case .sum_checking: return "checking"
            case .seeding: return "seeding"
            case .filehosting_waiting: return "waiting"
            case .extracting: return "extracting"
            case .error: return "error"
            default:
                return ""
            }
        }
        
        var downloadResumeButtonState: PZDownloadResumeButton.State
        {
            switch self.taskStatus
            {
            case .waiting: return PZDownloadResumeButton.State.wait
            case .downloading: return PZDownloadResumeButton.State.pause
            case .paused: return PZDownloadResumeButton.State.resume
            case .finishing: return PZDownloadResumeButton.State.wait
            case .finished: return PZDownloadResumeButton.State.done
            case .sum_checking: return PZDownloadResumeButton.State.wait
            case .seeding: return PZDownloadResumeButton.State.done
            case .filehosting_waiting: return PZDownloadResumeButton.State.wait
            case .extracting: return PZDownloadResumeButton.State.wait
            case .error: return PZDownloadResumeButton.State.stopped
            default:
                return PZDownloadResumeButton.State.stopped
            }
        }

        var taskStatusSortKey: UInt
        {
            switch self.taskStatus
            {
            case .error: return 0
            case .paused: return 1

            case .filehosting_waiting: return 2
            case .waiting: return 3
            case .sum_checking: return 4

            case .downloading: return 5

            case .extracting: return 6
            case .finishing: return 7
            case .finished: return 8

            case .seeding: return 9
            default:
                return 100
            }
        }

        var description: String
        {
            let id: String = self.id == nil ? "<null>" : self.id!
            let statusText: String = self.status_value == nil ? "<null>" : self.status_value!
            let typeText: String = self.type_value == nil ? "<null>" : self.type_value!
            let title: String = self.title == nil ? "<null>" : self.title!
            let totalSizeText: String = self.size == nil ? "<null>" : self.totalSizeFormatted
            
            return "\(id). \(statusText). \(typeText). \(title) (\(totalSizeText))"
        }
    }

    var total: Int?
    var offset: Int?
    var taskObjectList: [TaskObject] = []
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.total = dataObject["total"] as? Int
        self.offset = dataObject["offset"] as? Int

        let list: NSArray? = dataObject["tasks"] as? NSArray
        
        if (list != nil)
        {
            for item in list!
            {
                if let taskObjectItem = item as? NSDictionary
                {
                    let taskObject: TaskObject = TaskObject(dataObject: taskObjectItem)
                    
                    self.taskObjectList.append(taskObject)
                }
            }
            
            self.sortByStateAndTitle()
        }
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        var lines = ""
        
        lines += "total: \(self.total!)\n"
        
        let taskList: [TaskObject] = self.taskObjectList
        
        for taskItem: TaskObject in taskList
        {
            lines += "- \(taskItem.description)\n"
        }
        
        return lines
    }

    var countInProgressTaskObjects: Int
    {
        var count: Int = 0;
        
        for taskItem: TaskObject in self.taskObjectList
        {
            if (taskItem.taskStatus == TaskObject.Status.downloading ||
                taskItem.taskStatus == TaskObject.Status.finishing ||
                taskItem.taskStatus == TaskObject.Status.sum_checking ||
                taskItem.taskStatus == TaskObject.Status.extracting)
            {
                count += 1
            }
        }
        
        return count
    }

    var countCompletedTaskObjects: Int
    {
        var count: Int = 0;
        
        for taskItem: TaskObject in self.taskObjectList
        {
            if (taskItem.taskStatus == TaskObject.Status.finished ||
                taskItem.taskStatus == TaskObject.Status.seeding)
            {
                count += 1
            }
        }
        
        return count
    }
    
    private func sortByStateAndTitle()
    {
        self.taskObjectList.sort(by:
        {
            (taskObject1, taskObject2) -> Bool in

            if (taskObject1.taskStatusSortKey == taskObject2.taskStatusSortKey)
            {
                return (taskObject2.taskTitle < taskObject1.taskTitle)
            }
            else
            {
                return (taskObject2.taskStatusSortKey < taskObject1.taskStatusSortKey)
            }
        })

    }

}
