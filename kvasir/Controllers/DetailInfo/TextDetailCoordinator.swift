//
//  TextDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class TextDetailCoordinator {
    private var mode = CoordinatorMode.local
    private(set) var digestType = DigestType.sentence
    private var digestId = ""
    private(set) var model: RealmWordDigest?
    private var data = TextDetailViewModel(id: "", content: "", bookName: "", authors: "", translators: "", publisher: "", pageIndex: "", updatedAt: "") {
        didSet {
            reload?(data)
        }
    }
    
    private var realmNotificationToken: NotificationToken?
    
    var reload: ((_ data: TextDetailViewModel) -> Void)?
    
    init(mode: CoordinatorMode = .local, digestType: DigestType = .sentence, digestId: String) {
        self.mode = mode
        self.digestId = digestId
        self.digestType = digestType
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        self.realmNotificationToken?.invalidate()
    }
    
    func fetchData() {
        switch mode {
        case .local:
            fetchLocalData()
        case .remote:
            fetchRemoteData()
        }
    }
    
    private func fetchLocalData() {
        switch digestType {
        case .sentence:
            guard let result = RealmSentence.queryObjectWithPrimaryKey(of: RealmSentence.self, key: digestId) else { return }
            
            func setData(object: RealmSentence) {
                model = object
                data = object.display()
            }
            
            realmNotificationToken = result.observe { [weak self] change in
                switch change {
                case .change:
                    setData(object: result)
                case .deleted: fallthrough
                case .error:
                    break
                }
            }
            setData(object: result)
        case .paragraph:
            guard let result = RealmParagraph.queryObjectWithPrimaryKey(of: RealmParagraph.self, key: digestId) else { return }
            
            func setData(object: RealmParagraph) {
                model = object
                data = object.display()
            }
            
            realmNotificationToken = result.observe({ change in
                switch change {
                case .change:
                    setData(object: result)
                case .deleted: fallthrough
                case .error:
                    break
                }
            })
            setData(object: result)
        }
    }
    
    private func fetchRemoteData() {
        
    }
    
    func delete() -> Bool {
        return model?.delete() ?? false
    }
}

private extension RealmWordDigest {
    func display() -> TextDetailViewModel {
        let updateAtString = updatedAt.string(withFormat: "yyyy-MM-dd")
        let authorsString = book?.authors.map({ (ele) -> String in
            return ele.name
        }).joined(separator: "\n") ?? ""
        let translatorsString = book?.translators.map({ (ele) -> String in
            return ele.name
        }).joined(separator: "\n") ?? ""
        let pageIndexString = pageIndex == -1 ? "---" : "\(pageIndex)"
        return TextDetailViewModel(id: id, content: content, bookName: book?.name ?? "", authors: authorsString, translators: translatorsString, publisher: book?.publisher ?? "", pageIndex: pageIndexString, updatedAt: updateAtString)
    }
}
