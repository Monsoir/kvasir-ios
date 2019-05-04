//
//  WordDigestInfoViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/16/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka
import FontAwesome_swift
import RealmSwift
import SwifterSwift

class CreateDigestInfoViewController<Digest: RealmWordDigest>: FormViewController {
    
    private var digest: Digest?
    private var creating = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    init(digest: Digest, creating: Bool = true) {
        self.creating = creating
        self.digest = digest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
}

private extension CreateDigestInfoViewController {
    func setupNavigationBar() {
        
    }
    
    func setupSubviews() {
        tableView.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        let digestRelatedSection = Section("摘录相关")
        digestRelatedSection <<< IntRow() {
            $0.tag = "pageIndex"
            $0.title = "摘录页码"
        }
        form +++ digestRelatedSection
        
        let bookRelatedSection = Section(header: "书籍相关", footer: "") {
            $0.tag = "book"
        }
        bookRelatedSection <<< TextRow() {
            $0.title = "书籍名称"
            $0.tag = "bookName"
            $0.baseCell.isUserInteractionEnabled = false
            $0.hidden = Condition.function(["bookId"], { (form) -> Bool in
                let bookIdRow = form.rowBy(tag: "bookId") as? LabelRow
                return bookIdRow?.value.isNilOrEmpty ?? true
            })
        }
        bookRelatedSection <<< TextRow() {
            $0.title = "书籍翻译名称"
            $0.tag = "bookLocaleName"
            $0.baseCell.isUserInteractionEnabled = false
            $0.hidden = Condition.function(["bookId"], { (form) -> Bool in
                let bookIdRow = form.rowBy(tag: "bookId") as? LabelRow
                return bookIdRow?.value.isNilOrEmpty ?? true
            })
        }
        bookRelatedSection <<< TextRow() {
            $0.title = "ISBN"
            $0.tag = "isbn"
            $0.baseCell.isUserInteractionEnabled = false
            $0.hidden = Condition.function(["bookId"], { (form) -> Bool in
                let bookIdRow = form.rowBy(tag: "bookId") as? LabelRow
                return bookIdRow?.value.isNilOrEmpty ?? true
            })
        }
        bookRelatedSection <<< TextRow() {
            $0.title = "出版商"
            $0.tag = "publisher"
            $0.baseCell.isUserInteractionEnabled = false
            $0.hidden = Condition.function(["bookId"], { (form) -> Bool in
                let bookIdRow = form.rowBy(tag: "bookId") as? LabelRow
                return bookIdRow?.value.isNilOrEmpty ?? true
            })
        }
        bookRelatedSection <<< ButtonRow() { (row: ButtonRow) in
            row.title = "关联一本书籍"
            }.onCellSelection({ [weak self] (cell, row) in
                let vc = BookListViewController(selectCompletion: { [weak self] (book) in
                    self?.bookDidSelect(book: book)
                    self?.navigationController?.popViewController()
                })
                self?.navigationController?.pushViewController(vc, completion: nil)
            })
        bookRelatedSection <<< LabelRow() {
            $0.hidden = true
            $0.tag = "bookId"
        }
        form +++ bookRelatedSection
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
    }
}

extension CreateDigestInfoViewController {
    func getFormValues() -> [String: Any] {
        let values = form.values(includeHidden: true)
        let pageIndex = values["pageIndex"] as? Int ?? -1
        let bookId = values["bookId"] as? String ?? ""
        return [
            "pageIndex": pageIndex,
            "bookId": bookId,
        ]
    }
}

private extension CreateDigestInfoViewController {
    func bookDidSelect(book: RealmBook) {
        let values: [String: Any] = [
            "bookId": book.id,
            "bookName": book.name,
            "bookLocaleName": book.localeName,
            "isbn": book.isbn,
            "publisher": book.publisher,
        ]
        form.setValues(values)
        form.sectionBy(tag: "book")?.reload()
    }
}

private struct DigestRecoverViewModel {
    var bookName: String
    var authors: [String]
    var translators: [String]
    var publisher: String
    var pageIndex: Int
}
