//
//  PZSynoDownloadStationTaskControlObject.swift
//  synoToolTest
//
//  Created by Piotr on 16.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoDownloadStationTaskControlObject: PZSynoObject
{
    class TaskControlResult
    {
        var id: String?
        var error: Int?
        
        var isSuccess: Bool
        {
            return (error != nil && error! == 0)
        }
        
        init(dataObject: NSDictionary)
        {
            self.id = dataObject["id"] as? String
            self.error = dataObject["error"] as? Int
        }

        var description: String
        {
            return "id: \(self.id!) error: \(self.error!)"
        }
    }
    
    var taskControlResultList: [TaskControlResult] = []

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)

        for item in dataObject
        {
            if let taskControlResultObject = item as? NSDictionary
            {
                let taskControlResult: TaskControlResult = TaskControlResult(dataObject: taskControlResultObject)
                
                self.taskControlResultList.append(taskControlResult)
            }
        }
    }
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        var lines = ""
        
        let list: [TaskControlResult] = self.taskControlResultList
        
        for item: TaskControlResult in list
        {
            lines += "- \(item.description)\n"
        }
        
        return lines
    }

}
