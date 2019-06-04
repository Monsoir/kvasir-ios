//
//  KvasirWebServerHandlers.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import GCDWebServer

struct KvasirWebServerHandlers {
    static let test: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        GlobalDefaultDispatchQueue.async {
            // get data
            let response = GCDWebServerDataResponse(jsonObject: ["hello": "world again"])
            
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            completionBlock(response)
        }
    }
    
    static let test2: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        GlobalDefaultDispatchQueue.async {
            // write file
            let filename = "backup.json"
            
            guard let path = SystemDirectories.tmp.url?.appendingPathComponent(filename) else {
                completionBlock(GCDWebServerErrorResponse(statusCode: 500))
                return
            }
            
            let data = ["hello": "world"]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                completionBlock(GCDWebServerErrorResponse(statusCode: 500))
                return
            }
            
            guard let jsonStringified = String(data: jsonData, encoding: .utf8) else {
                completionBlock(GCDWebServerErrorResponse(statusCode: 500))
                return
            }
            
            do {
                try jsonStringified.write(to: path, atomically: false, encoding: .utf8)
            } catch {
                completionBlock(GCDWebServerErrorResponse(statusCode: 500))
                return
            }
            
            // get data
            let response = GCDWebServerFileResponse(file: path.droppedScheme()!.absoluteString, isAttachment: true)

            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif

            completionBlock(response)
        }
    }
    
    static let export: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        let maintainer = DataMaintainer.shared
        maintainer.export(completion: { (exportingURL) in
            guard let url = exportingURL else {
                let response = GCDWebServerErrorResponse(statusCode: 500)
                
                #if DEBUG
                // solve opaque response
                response.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
                #endif
                
                completionBlock(response)
                return
            }
            
            let response = GCDWebServerFileResponse(file: url.droppedScheme()!.absoluteString, isAttachment: true)
            
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            completionBlock(response)
        })
    }
}
