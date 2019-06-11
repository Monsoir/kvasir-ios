//
//  SearchResultCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 6/6/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

private let PageSize = 5
class DigestSearchResultCoordinator: NSObject, Configurable {
    
    private var results: Results<RealmWordDigest>?
//    private var paragraphResults: Results<RealmParagraph>?
    private var pageIndex = 0
    private(set) var searchResults = [DigestSearchResult]()
    private var searchType = SearchType.sentence
    private var keyword = ""
    private var noMore = false
    
    private var startIndex: Int {
        return pageIndex * PageSize
    }
    private var endIndex: Int {
        // inclusive
        return startIndex + PageSize - 1
    }
    
    private var configuration: Configurable.Configuration
    required init(configuration: Configuration = [:]) {
        self.configuration = configuration
    }
    
    private var runloopPort: NSMachPort?
    private var runloop: RunLoop?
    private var _thread: Thread?
    private var shouldKeepRunning = false
    
    private var thread: Thread {
        if _thread == nil {
            _thread = Thread(target: self, selector: #selector(asyncRun), object: nil)
            _thread?.name = "Kvasir.Digest.Search"
            _thread?.start()
        }
        return _thread!
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    @objc private func asyncRun() {
        autoreleasepool { () -> Void in
            // 获取 RunLoop
            runloop = RunLoop.current
            
            // 创建并添加 source 到 RunLoop
            // 否则只会立刻退出
            runloopPort = NSMachPort()
            runloop?.add(runloopPort!, forMode: .common)
            
            shouldKeepRunning = true
            while shouldKeepRunning && runloop!.run(mode: .default, before: Date.distantFuture) {} // 这是分界线，在这里不断在进行类似死循环的循环
            
            // 上面是 RunLoop 不断在跑圈
            // 下面是 RunLoop 跑完圈
            
            if Thread.current != thread {
                fatalError("Current thread is \(String(describing: Thread.current.name)), search opeartions should happend on the \(thread.name!)")
            }
            
            if !thread.isCancelled {
                thread.cancel()
            }
            _thread = nil
            
            // 移除 port
            if let runloopPort = runloopPort {
                runloop?.remove(runloopPort, forMode: .common)
            }
            runloopPort = nil
            
            
            // 移除 runloop
            if let runloop = runloop {
                CFRunLoopStop(runloop.getCFRunLoop())
            }
            runloop = nil
        }
    }
    
    @objc private func asyncStop() {
        shouldKeepRunning = false
    }
    
    @objc private func asyncSetupQuery(_ userInfo: [String: Any]) {
        guard let completion = userInfo["completion"] as? ((_: Bool) -> Void) else { return }
        
        debugPrint("asyncSetupQuery: \(Thread.current)")
        autoreleasepool { () -> Void in
            do {
                let realm = try Realm()
                let filteringPredicate = "content CONTAINS[c] '\(keyword)'" // 大小写忽略，模糊匹配
                switch searchType {
                case .sentence:
                    self.results = realm.objects(RealmWordDigest.self)
                                        .filter("\(filteringPredicate) AND \(#keyPath(RealmWordDigest.category)) = \(RealmWordDigest.Category.sentence)")
                                        .sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
                    if self.results?.count ?? 0 <= 0 {
                        noMore = true
                    }
                case .paragraph:
                    self.results = realm.objects(RealmWordDigest.self)
                                        .filter("\(filteringPredicate) AND \(#keyPath(RealmWordDigest.category)) = \(RealmWordDigest.Category.paragraph)")
                                        .sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
                    if self.results?.count ?? 0 <= 0 {
                        noMore = true
                    }
                }
                // 到此为止，这里应该还是在一个子线程，即 self.thread
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    @objc private func asyncRequestData(_ userInfo: [String: Any]) {
        guard let completion = userInfo["completion"] as? ((_: [DigestSearchResult]) -> Void), let results = results else { return }
        guard !noMore else {
            completion(searchResults)
            return
        }
        
        let startIndex = self.startIndex
        let endIndex = (results.count - 1) > (self.endIndex) ? self.endIndex : results.count - 1
        
        for ele in results[startIndex...endIndex] {
            let ranges = ele.content.ranges(of: keyword, options: .caseInsensitive)
            for range in ranges {
                let steps = 10
                let lowestIndex = ele.content.index(range.lowerBound, offsetBy: -steps, limitedBy: ele.content.startIndex)
                let uppestIndex = ele.content.index(range.lowerBound, offsetBy: steps, limitedBy: ele.content.endIndex)
                let content = String(ele.content[(lowestIndex ?? range.lowerBound) ..< (uppestIndex ?? range.upperBound)])
                let bookName: String
                bookName = ele.book?.name ?? ""
                let result = DigestSearchResult(id: ele.id, content: content, bookName: bookName, range: content.range(of: keyword, options: .caseInsensitive)!)
                searchResults.append(result)
            }
        }
        pageIndex += 1
        completion(searchResults)
    }
    
    private func sameConditions(searchingType: SearchType, keyword: String) -> Bool {
        return searchingType == self.searchType && keyword == self.keyword
    }
}

// MARK: - 公开方法
extension DigestSearchResultCoordinator {
    func setupQuery(by content: String, completion: @escaping ((_: Bool) -> Void)) {
        guard !content.isEmpty else { return }
        guard content != keyword else { return }
        
        cleanupForNext()
        keyword = content
        let infos: [String: Any] = [
            "completion": completion,
        ]
        perform(#selector(asyncSetupQuery(_:)), on: thread, with: infos, waitUntilDone: false, modes: [RunLoop.Mode.common.rawValue])
    }
    
    func requestData(completion:  @escaping ((_: [DigestSearchResult]) -> Void)) {
        let infos: [String: Any] = [
            "completion": completion,
        ]
        perform(#selector(asyncRequestData(_:)), on: thread, with: infos, waitUntilDone: false, modes: [RunLoop.Mode.common.rawValue])
    }
    
    func cleanupForNext() {
        pageIndex = 0
        results = nil
        searchResults.removeAll()
        keyword = ""
        noMore = false
    }
    
    func reclaimThread() {
        if _thread != nil {
            perform(#selector(asyncStop), on: thread, with: nil, waitUntilDone: false, modes: [RunLoop.Mode.common.rawValue])
        }
    }
}
