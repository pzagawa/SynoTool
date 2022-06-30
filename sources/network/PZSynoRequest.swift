//
//  PZSynoRequest.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoRequest<Object: PZSynoObject>: PZRequest
{
    typealias Completion = (_ responseObject: PZSynoResponseObject<Object>) -> Void
    
    private var session: URLSession!

    override init()
    {
        super.init()
        
        self.session = URLSession(configuration: PZRequest.sessionConfiguration)
    }
    
    func isRetryWithResponse(responseObject: PZSynoResponseObject<Object>) -> Bool
    {
        if (responseObject.isStatusCodeOK == false || responseObject.isSuccess == false)
        {
            if (self.retryNumber == 0)
            {
                print("[PZSynoRequest] isRetryWithResponse. RESPONSE: \(Object.self) STATUS: \(responseObject.statusText)")
            }

            if (self.retryNumber < PZRequest.MAX_RETRY_COUNT)
            {
                self.retryNumber += 1
                
                let timeToWait = (0.5 * Double(retryNumber))
                
                self.waitSeconds(seconds: timeToWait)
                
                return true
            }
        }
        
        return false
    }
    
    func request(httpMethod: HTTPMethod, url: URL?, bodyData: Data?, retry: Bool, completion: @escaping Completion)
    {
        if (url == nil)
        {
            print("[PZSynoRequest] request url is null")

            return
        }
        
        let request: URLRequest = self.createRequest(httpMethod: httpMethod, url: url!)

        PZSynoRequest.retainRequest(request: self)
        
        let task: URLSessionUploadTask = self.session.uploadTask(with: request, from: bodyData)
        {
            [weak self] (data: Data?, response: URLResponse?, error: Error?) in

            let responseObject: PZSynoResponseObject<Object> = PZSynoResponseObject<Object>(data: data, response: response, error: error)

            if retry
            {
                if let this = self
                {
                    if (this.isRetryWithResponse(responseObject: responseObject))
                    {
                        this.request(httpMethod: httpMethod, url: url, bodyData: bodyData, retry: retry, completion: completion);
                        
                        PZSynoRequest.releaseRequest(request: this)
                        
                        return
                    }
                }
            }
            
            completion(responseObject)

            if let this = self
            {
                PZSynoRequest.releaseRequest(request: this)
            }
        }
        
        task.resume()
    }
    
}
