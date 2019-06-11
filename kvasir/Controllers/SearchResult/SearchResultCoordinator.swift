//
//  SearchResultCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 6/6/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class DigestSearchResultCoordinator: NSObject, Configurable {
    
    static let PageSize = 5
    
    private var results: Results<RealmWordDigest>?
    private(set) var pageIndex = 0
    private(set) var searchResults = [DigestSearchResult]()
    private var searchType = SearchType.sentence
    private var keyword = ""
    private var noMore = false
    
    private var startIndex: Int {
        return pageIndex * DigestSearchResultCoordinator.PageSize
    }
    private var endIndex: Int {
        // inclusive
        return startIndex + DigestSearchResultCoordinator.PageSize - 1
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
                                        .filter("\(filteringPredicate) AND \(#keyPath(RealmWordDigest.category)) == %@", RealmWordDigest.Category.sentence.rawValue)
                                        .sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
                    if self.results?.count ?? 0 <= 0 {
                        noMore = true
                    }
                case .paragraph:
                    self.results = realm.objects(RealmWordDigest.self)
                                        .filter("\(filteringPredicate) AND \(#keyPath(RealmWordDigest.category)) == %@", RealmWordDigest.Category.paragraph.rawValue)
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
        guard startIndex <= endIndex else {
            noMore = true
            return
        }
        
        for ele in results[startIndex...endIndex] {
            let ranges = ele.content.ranges(of: keyword, options: .caseInsensitive)
            
            let steps = 10 // 前后最多拿多 10 个字符
            
            // 对同一条记录，查找所有的匹配项
//            for range in ranges {
//                let lowestIndex = ele.content.index(range.lowerBound, offsetBy: -steps, limitedBy: ele.content.startIndex)
//                let uppestIndex = ele.content.index(range.upperBound, offsetBy: steps, limitedBy: ele.content.endIndex)
//                let content = String(ele.content[(lowestIndex ?? range.lowerBound) ..< (uppestIndex ?? range.upperBound)]).replacingOccurrences(of: "\n", with: " ")
//                let bookName: String
//                bookName = ele.book?.name ?? ""
//                let result = DigestSearchResult(id: ele.id, content: content, bookName: bookName, range: content.range(of: keyword, options: .caseInsensitive)!)
//                searchResults.append(result)
//            }
            
            // 对同一条记录，只获取第一个匹配项
            if let range = ranges.first {
                let lowestIndex = ele.content.index(range.lowerBound, offsetBy: -steps, limitedBy: ele.content.startIndex)
                let uppestIndex = ele.content.index(range.upperBound, offsetBy: steps, limitedBy: ele.content.endIndex)
                let content = String(ele.content[(lowestIndex ?? range.lowerBound) ..< (uppestIndex ?? ele.content.endIndex)]).replacingOccurrences(of: "\n", with: " ")
                let bookName = ele.book?.name ?? ""
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
    
    
    private func sameSearchInput(keyword: String, type: SearchType) -> Bool {
        return self.keyword == keyword && self.searchType == type
    }
}

// MARK: - 公开方法
extension DigestSearchResultCoordinator {
    func setupQuery(by content: String, of type: SearchType, completion: @escaping ((_: Bool) -> Void)) {
//        guard !content.isEmpty else {
//            return
//        }
        guard !sameSearchInput(keyword: content, type: type) else { return }
        
        cleanupForNext()
        keyword = content
        searchType = type
        let infos: [String: Any] = [
            "completion": completion,
        ]
        perform(#selector(asyncSetupQuery(_:)), on: thread, with: infos, waitUntilDone: false, modes: [RunLoop.Mode.common.rawValue])
    }
    
    func requestData(completion:  @escaping ((_: [DigestSearchResult]) -> Void)) {
        guard !noMore else { return }
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
