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

private typealias InitialValues = (bookName: String, publisher: String, authors: [String], translators: [String], pageIndex: Int?)

class WordDigestInfoViewController: FormViewController {
    
    private var digestType = DigestType.sentence
    private var digest: RealmWordDigest?
    private var creating = true
    
    private lazy var nextItem: UIBarButtonItem = UIBarButtonItem(title: "记录正文", style: .done, target: self, action: #selector(actionNext))
    private lazy var submitItem: UIBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionSubmit))
    
    private var didEnter = false
    
    private var initialValues: InitialValues {
        get {
            guard !creating,  let digest = digest else { return ("", "", [], [], nil)}
            return (
                digest.bookName,
                digest.publisher,
                Array(digest.authors),
                Array(digest.translators),
                digest.pageIndex == -1 ? nil : digest.pageIndex
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupNavigationBar()
        setupSubviews()
        
        if !didEnter {
            let bookNameRow = form.rowBy(tag: "bookName") as! TextRow
            bookNameRow.cell.textField.becomeFirstResponder()
            didEnter = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearupNotification()
    }
    
    init(digestType: DigestType = .sentence, digest: RealmWordDigest, creating: Bool = true) {
        self.digestType = digestType
        self.digest = digest
        self.creating = creating
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

private extension WordDigestInfoViewController {
    func setupNavigationBar() {
        title = "基本信息"
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = creating ? nextItem : submitItem
    }
    
    func setupSubviews() {
        
        let values = initialValues
        
        let bookRelatedSection = Section("书籍相关")
        bookRelatedSection <<< TextRow() {
            $0.tag = "bookName"
            $0.title = "书籍名称"
            $0.value = values.bookName
        }
        bookRelatedSection <<< TextRow() {
            $0.tag = "publisher"
            $0.title = "出版商"
            $0.value = values.publisher
        }
        
        let authorsSection = MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                                header: "作者",
                                                footer: "") {
                                                    $0.tag = "authors"
                                                    $0.addButtonProvider = { section in
                                                        let buttonRow = ButtonRow() {
                                                            $0.title = "添加一个作者"
                                                        }
                                                        buttonRow.cellUpdate({ (cell, row) in
                                                            cell.textLabel?.textAlignment = .left
                                                        })
                                                        return buttonRow
                                                    }
                                                    $0.multivaluedRowToInsertAt = { index in
                                                        return TextRow() {
                                                            $0.placeholder = "作者 \(index)"
                                                        }
                                                    }
                                                    
                                                    let eles = values.authors
                                                    if eles.count <= 0 {
                                                        $0 <<< TextRow() {
                                                            $0.placeholder = "作者"
                                                        }
                                                    } else {
                                                        let section = $0
                                                        eles.forEach({ (ele) in
                                                            section <<< TextRow() {
                                                                $0.value = ele
                                                            }
                                                        })
                                                    }
        }
        
        let translatorSection = MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                                header: "译者",
                                                footer: "") {
                                                    $0.tag = "translators"
                                                    $0.addButtonProvider = { section in
                                                        let buttonRow = ButtonRow() {
                                                            $0.title = "添加一个译者"
                                                        }
                                                        buttonRow.cellUpdate({ (cell, row) in
                                                            cell.textLabel?.textAlignment = .left
                                                        })
                                                        return buttonRow
                                                    }
                                                    $0.multivaluedRowToInsertAt = { index in
                                                        return TextRow() {
                                                            $0.placeholder = "译者 \(index)"
                                                        }
                                                    }
                                                    
                                                    let eles = values.translators
                                                    if eles.count <= 0 {
                                                        $0 <<< TextRow() {
                                                            $0.placeholder = "译者"
                                                        }
                                                    } else {
                                                        let section = $0
                                                        eles.forEach({ (ele) in
                                                            section <<< TextRow() {
                                                                $0.value = ele
                                                            }
                                                        })
                                                    }
        }
        
        let digestRelatedSection = Section("摘录相关")
        digestRelatedSection <<< IntRow() {
            $0.tag = "pageIndex"
            $0.title = "摘录页码"
            $0.value = values.pageIndex
        }
        
        form +++ bookRelatedSection
        form +++ authorsSection
        form +++ translatorSection
        form +++ digestRelatedSection
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
    }
}


// MARK: - Actions
private extension WordDigestInfoViewController {
    func putFormValuesToModel() {
        let values = form.values()
        let authors = values["authors"] as? [String] ?? []
        let translators = values["translators"] as? [String] ?? []
        let bookName = values["bookName"] as? String ?? ""
        let pageIndex = values["pageIndex"] as? Int ?? -1
        let publisher = values["publisher"] as? String ?? ""
        
        digest?.authors.removeAll()
        digest?.authors.append(objectsIn: authors)
        
        digest?.translators.removeAll()
        digest?.translators.append(objectsIn: translators)
        
        digest?.bookName = bookName
        digest?.pageIndex = pageIndex
        digest?.publisher = publisher
    }
    
    @objc func actionSubmit() {
        putFormValuesToModel()
        
        var savedResult = false
        switch digestType {
        case .sentence:
            savedResult = (digest as! RealmSentence).update()
        case .paragraph:
            savedResult = (digest as! RealmParagraph).update()
        }
        
        guard savedResult else { return }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionNext() {
        putFormValuesToModel()
        
        let nextVC = TextEditViewController(digestType: digestType, digest: digest!, creating: creating)
        navigationController?.pushViewController(nextVC)
    }
}


// MARK: - Notifications
private extension WordDigestInfoViewController {
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditing), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndEditing), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    func clearupNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didBeginEditing() {
        nextItem.isEnabled = false
    }
    
    @objc func didEndEditing() {
        nextItem.isEnabled = true
    }
}

private struct DigestRecoverViewModel {
    var bookName: String
    var authors: [String]
    var translators: [String]
    var publisher: String
    var pageIndex: Int
}

private extension RealmWordDigest {
    func displayInfo() -> DigestRecoverViewModel {
        return DigestRecoverViewModel(bookName: bookName, authors: Array(authors), translators: Array(translators), publisher: publisher, pageIndex: pageIndex)
    }
}
