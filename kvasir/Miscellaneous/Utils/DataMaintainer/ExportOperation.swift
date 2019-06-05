//
//  BackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class ExportOperation: DataOperation {
    
    /// 备份文件路径
    /// - 以 file: 协议开头的
    private(set) var backupPath: URL
    
    override init(path: URL) {
        self.backupPath = path
        super.init(path: path)
    }
    
    override func doBusiness() {
        // 获取二进制数据
        guard let jsonData = provideData() else {
            cancel()
            return
        }
        
        // 二进制数据转 JSON 字符串
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            cancel()
            return
        }
        
        guard !isCancelled else { return }
        
        // 将 JSON 存入文件
        do {
            try jsonString.write(to: backupPath, atomically: false, encoding: .utf8)
        } catch {
            cancel()
            return
        }
    }
}
