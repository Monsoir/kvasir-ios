//
//  AppConstants.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct AppConstants {
    static let tagInitiatedKey = "tag-data-initiated"
    struct Paths {
        /// 数据库文件路径
        static let databaseFile = SystemDirectories.document.url?
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("kvasir.realm")
        
        /// 导出数据文件夹路径
        static let exportingFileDirectory = SystemDirectories.tmp.url?.appendingPathComponent("export", isDirectory: true)
        /// 导入数据压缩文件路径
        static let importingFilePath = SystemDirectories.tmp.url?.appendingPathComponent("imported_backup.zip")
        /// 导入数据解压文件夹路径
        static let importingUnzipDirectory = SystemDirectories.tmp.url?.appendingPathComponent("import", isDirectory: true)
    }
    struct WebServer {
        /// 服务监听端口
        static let port = 8080
        
        /// 网页静态文件存放路径
        static let websiteLocation = SystemDirectories.document.url?
            .appendingPathComponent("website", isDirectory: true)
            .appendingPathComponent("build", isDirectory: true)
        static let websiteBuiltitLocaltion = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "website/build")
    }
}

struct AppNotification {
    struct Name {
        /// Digest 与 Tag 之间的关系将发生变化时触发
        /// - 发生变化前，发送一次通知，让订阅方准备好，缓存好数据
        /// - 在全局派发 default 队列进行派发
        /// - userInfo: tagId, digestType, digestIdSet, (changeSuccess: Bool)
        static let relationBetweenDigestAndTagWillChange = "relationBetweenDigestAndTagWillChange"
        
        /// Digest 与 Tag 之间的关系发生了变化时触发
        /// - 发生变化后，发送一次通知，让订阅方处理
        /// - 在全局派发 default 队列进行派发
        static let relationBetweenDigestAndTagDidChange = "relationBetweenDigestAndTagDidChange"
        
        /// 本地服务器任务状态发生变化时触发
        /// - 如 normal -> importing, normal -> exporting
        /// - userInfo: (status: KvasirWebServer.TaskStatus)
        static let serverTaskStatusDidChange = "serverTaskStatusDidChange"
    }
}
