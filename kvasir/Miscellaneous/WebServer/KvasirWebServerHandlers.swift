//
//  KvasirWebServerHandlers.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import GCDWebServer
import PKHUD

struct KvasirWebServerHandlers {
    static let test: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        GlobalDefaultDispatchQueue.async {
            // get data
            let response = GCDWebServerDataResponse(jsonObject: ["hello": "world again"])
            response?.statusCode = 500
            
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
        
        MainQueue.async {
            HUD.show(.labeledProgress(title: "正在导出", subtitle: nil))
        }
        
        DataMaintainer().export(completion: { (exportingURL, message) in
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
                object: nil,
                userInfo: ["status": KvasirWebServer.TaskStatus.normal]
            )
            
            guard let url = exportingURL else {
                let response = GCDWebServerDataResponse(jsonObject: ["message": message ?? "未知错误"])
                response?.statusCode = 500
                #if DEBUG
                // solve opaque response
                response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
                #endif
                completionBlock(response)
                
                MainQueue.async {
                    HUD.flash(.labeledError(title: message ?? "未知错误", subtitle: nil), delay: 1.5)
                }
                
                return
            }
            
            let response = GCDWebServerFileResponse(file: url.droppedScheme()!.absoluteString, isAttachment: true)
            
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            MainQueue.async {
                HUD.flash(.labeledSuccess(title: "导出成功", subtitle: "请在网页上接收文件"), delay: 1.5)
            }
            
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
            // 有与用户上传的文件同名的文件存在，先删除，否则抛异常
            if FileManager.default.fileExists(atPath: AppConstants.Paths.importingFilePath!.droppedScheme()!.absoluteString) {
                try FileManager.default.removeItem(at: AppConstants.Paths.importingFilePath!)
            }
            
            // 若需要上传的文件，则需要立刻移动文件，否则 GCDWebServerFileRequest 对象释放后，自动删除文件
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
        
        // 通知 webserver 任务状态为「导入」
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
            object: nil,
            userInfo: ["status": KvasirWebServer.TaskStatus.importing]
        )
        
        MainQueue.async {
            HUD.show(.labeledProgress(title: "正在导入", subtitle: nil))
        }
        
        DataMaintainer().import(completion: { (success, message) in
            // 通知 webserver 的任务状态变化为正常
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: AppNotification.Name.serverTaskStatusDidChange),
                object: nil,
                userInfo: ["status": KvasirWebServer.TaskStatus.normal]
            )
            
            // 删除导入文件，防止下次接收时出错
            // 创建同名文件抛异常
            if FileManager.default.fileExists(atPath: (AppConstants.Paths.importingFilePath?.droppedScheme()!.absoluteString)!) {
                do {
                    try FileManager.default.removeItem(at: AppConstants.Paths.importingFilePath!)
                } catch {}
            }
            
            guard success else {
                let response = GCDWebServerDataResponse(jsonObject: ["message": message ?? "未知错误"])
                response?.statusCode = 500
                #if DEBUG
                // solve opaque response
                response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
                #endif
                completionBlock(response)
                
                MainQueue.async {
                    HUD.flash(.labeledError(title: message ?? "未知错误", subtitle: nil), delay: 1.5)
                }
                return
            }
            
            let response = GCDWebServerDataResponse(jsonObject: ["ok": true])
            #if DEBUG
            // solve opaque response
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            #endif
            
            MainQueue.async {
                HUD.flash(.labeledSuccess(title: "导入成功", subtitle: nil), delay: 1.5)
            }
            
            completionBlock(response)
        })
    }
}
