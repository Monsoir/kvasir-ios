//
//  ConcurrentableOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/5/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

private struct ObservingKeys {
    static let isFinished = "isFinished"
    static let isExecuting = "isExecuting"
}

class ConcurrentableOperation: Operation {
    private var _executing = false
    private var _finished = false
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
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
    
    override func cancel() {
        isExecuting = false
        super.cancel()
        isFinished = false
    }
}
