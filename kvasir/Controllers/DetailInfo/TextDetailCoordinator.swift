//
//  TextDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class TextDetailCoordinator<Digest: RealmWordDigest> {
    private var digestId = ""
    private(set) var model: Digest?
    private var data = TextDetailViewModel(id: "", content: "", bookName: "", authors: "", translators: "", publisher: "", pageIndex: "", updatedAt: "") {
        didSet {
            reload?(data)
        }
    }
    
    private var realmNotificationToken: NotificationToken?
    
    var reload: ((_ data: TextDetailViewModel) -> Void)?
    
    init(digestId: String) {
        self.digestId = digestId
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
        guard let result = Digest.queryObjectWithPrimaryKey(of: Digest.self, key: digestId) else { return }
        
        func setData(object: Digest) {
            model = object
            data = object.display()
        }
        
        realmNotificationToken = result.observe { change in
            switch change {
            case .change:
                setData(object: result)
            case .deleted: fallthrough
            case .error:
                break
            }
        }
        setData(object: result)
    }
    
    func updateContent(text: String, completion: @escaping RealmSaveCompletion) {
        guard let model = model else {
            completion(false)
            return
        }
        model.update(pairs: ["content": text]) { (success) in
            completion(success)
        }
    }
    
    func updateBookRef(book: RealmBook, completion: @escaping RealmSaveCompletion) {
        guard let model = model else {
            completion(false)
            return
        }
        let oldBook = model.book
        let newBook = book
        
        if Digest.self == RealmSentence.self {
            RealmBook.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "\(Digest.toMachine())s", inverseKey: "book", elements: [model] as! [RealmSentence] ) { (success) in
                completion(success)
            }
        } else if Digest.self == RealmParagraph.self {
            RealmBook.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "\(Digest.toMachine())s", inverseKey: "book", elements: [model] as! [RealmParagraph] ) { (success) in
                completion(success)
            }
        }
    }
    
    func delete(completion: @escaping RealmSaveCompletion) {
        model?.delete(completion: { (success) in
            completion(success)
        })
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
        let pageIndexString = pageIndex == -1 ? "$$$" : "\(pageIndex)"
        return TextDetailViewModel(id: id, content: content, bookName: book?.name ?? "", authors: authorsString, translators: translatorsString, publisher: book?.publisher ?? "", pageIndex: pageIndexString, updatedAt: updateAtString)
    }
}
