//
//  DataOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class DataOperation: ConcurrentableOperation {
    
    init(path: URL) {}
    
    override func start() {
        // 要在关键的阶段检查任务是否被取消（取消，停止）
        
        if isCancelled {
            isFinished = true
        }
        
        isExecuting = true
        doBusiness()
        isExecuting = false
        isFinished = true
    }
    
    func doBusiness() {
        fatalError("Remember to override `doBusiness` to define business logic")
    }
    
    func provideData() -> Data? {
        fatalError("Remember to override `provideData` to provide data to backup")
    }
}
