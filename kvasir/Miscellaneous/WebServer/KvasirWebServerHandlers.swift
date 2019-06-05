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
    
    static let export: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
            object: nil,
            userInfo: ["status": KvasirWebServer.TaskStatus.exporting]
        )
        let maintainer = DataMaintainer()
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
            
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
                object: nil,
                userInfo: ["status": KvasirWebServer.TaskStatus.normal]
            )
            
            let response = GCDWebServerFileResponse(file: url.droppedScheme()!.absoluteString, isAttachment: true)
            
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            completionBlock(response)
        })
    }
    
    
    /// Solving preflight OPTIONS response 501
    static let option: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        let response = GCDWebServerResponse(statusCode: 200)
        
        #if DEBUG
        // solve opaque response
        response.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
        
        // solve `Request header field content-type is not allowed by Access-Control-Allow-Headers in preflight response.`
        response.setValue("Content-Type", forAdditionalHeader: "Access-Control-Allow-Headers")
        #endif
        
        completionBlock(response)
    }
    
    static let `import`: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        guard let multipartRequest = request as? GCDWebServerFileRequest else {
            let response = GCDWebServerErrorResponse(statusCode: 500)
            #if DEBUG
            // solve opaque response
            response.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            completionBlock(response)
            return
        }
        
        let url = URL(fileURLWithPath: multipartRequest.temporaryPath)
        do {
            // 需要立刻移动文件，否则 GCDWebServerFileRequest 对象释放后，自动删除文件
            try FileManager.default.moveItem(at: url, to: AppConstants.Paths.importingFilePath!)
        } catch {
            let response = GCDWebServerErrorResponse(statusCode: 500)
            #if DEBUG
            // solve opaque response
            response.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            completionBlock(response)
            return
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
            object: nil,
            userInfo: ["status": KvasirWebServer.TaskStatus.importing]
        )
        
        DataMaintainer().import(completion: { (success) in
            if FileManager.default.fileExists(atPath: (AppConstants.Paths.importingFilePath?.droppedScheme()!.absoluteString)!) {
                do {
                    try FileManager.default.removeItem(at: AppConstants.Paths.importingFilePath!)
                } catch {
                    
                }
            }
            
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
                object: nil,
                userInfo: ["status": KvasirWebServer.TaskStatus.normal]
            )
            
            let response = GCDWebServerDataResponse(jsonObject: ["ok": true])
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            completionBlock(response)
        })
    }
}
