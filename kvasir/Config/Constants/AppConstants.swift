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
    static let dataBaseFile = SystemDirectories.document.url?
                    .appendingPathComponent("data", isDirectory: true)
                    .appendingPathComponent("kvasir.realm")
    struct WebServer {
        static let port = 8080
        static let websiteLocation = SystemDirectories.document.url?
            .appendingPathComponent("website", isDirectory: true)
            .appendingPathComponent("build", isDirectory: true)
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
    }
}
