//
//  DataOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

private struct ObservingKeys {
    static let isFinished = "isFinished"
    static let isExecuting = "isExecuting"
}

class DataOperation: Operation {
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
    
    init(path: URL) {}
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    override func cancel() {
        isExecuting = false
        super.cancel()
        isFinished = false
    }
    
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
