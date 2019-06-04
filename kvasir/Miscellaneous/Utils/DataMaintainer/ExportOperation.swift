//
//  BackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

private struct ObservingKeys {
    static let isFinished = "isFinished"
    static let isExecuting = "isExecuting"
}

class ExportOperation: Operation {
    
    /// 备份文件路径
    /// - 以 file: 协议开头的
    private(set) var backupPath: URL
    
    private var _executing = false
    private var _finished = false
    
    // 可并行
    override var isConcurrent: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: ObservingKeys.isExecuting)
            _executing = newValue
            didChangeValue(forKey: ObservingKeys.isExecuting)
        }
        get {
            return _executing
        }
    }
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: ObservingKeys.isFinished)
            _finished = newValue
            didChangeValue(forKey: ObservingKeys.isFinished)
        }
        get {
            return _finished
        }
    }
    
    init(path: URL) {
        self.backupPath = path
    }
    
    override func start() {
        // 要在关键的阶段检查任务是否被取消（取消，停止）
        
        if isCancelled {
            isFinished = true
        }
        
        isExecuting = true
        runBackup()
        isExecuting = false
        isFinished = true
    }
    
    private func runBackup() {
        guard let jsonData = provideData() else {
            cancel()
            return
        }
        
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
    
    func provideData() -> Data? {
        fatalError("Remember to override `provideData` to provide data to backup")
    }
}
