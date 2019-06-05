//
//  ImportOperation.swift
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

protocol ImportOperationDeleagte {
    /// 任务完成回调
    ///
    /// - Parameters:
    ///   - operation: 当前结束的任务
    ///   - isCompleted: 任务是否完成，当任务完美完成时为 true, 其他情况为 false
    ///   - msg: 任务不能完美完成的描述
    ///   - ros: Realm ObjectS, 转换成功后的 Realm 数据，处于 unmanaged 状态
    ///   - pos: Plain ObjectS, 关系的字典，最后统一根据关系字典将各个数据的关系连接起来
    func operation(_ operation: ImportOperation, isCompleted: Bool, msg: String?, ros: [RealmBasicObject]?, pos: [Codable]?)
}

class ImportOperation: DataOperation {
    
    var delegate: ImportOperationDeleagte?
    
    /// 导入文件路径
    /// - 以 file: 协议开头的
    private(set) var importPath: URL
    
    override init(path: URL) {
        self.importPath = path
        super.init(path: path)
    }
    
    override func doBusiness() {
        // 获取二进制数据
        guard let jsonData = provideData() else {
            delegate?.operation(self, isCompleted: false, msg: "数据获取失败", ros: nil, pos: nil)
            return
        }
        
        // 从二进制数据中还原 Realm 数据
        let result = recover(jsonData: jsonData)
        guard result.success else {
            delegate?.operation(self, isCompleted: false, msg: result.msg ?? "", ros: nil, pos: nil)
            return
        }
        
        delegate?.operation(self, isCompleted: true, msg: nil, ros: result.ros, pos: result.pos)
    }
    
    func recover(jsonData: Data) -> (success: Bool, msg: String?, ros: [RealmBasicObject]?, pos: [Codable]?) {
        fatalError("override `recover` to provide logic transforming data")
    }
    
    class var restoreKey: String {
        return "override me"
    }
    
    override func provideData() -> Data? {
        return try? Data(contentsOf: self.importPath, options: .uncachedRead)
    }
}
