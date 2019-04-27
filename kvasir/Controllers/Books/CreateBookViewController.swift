//
//  CreateBookViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka
import SwifterSwift
import FontAwesome_swift
import RealmSwift

private let HeaderHeight = 150.0 as CGFloat

class CreateBookViewController: FormViewController {
    
    private var creating = true
    private var book: RealmBook
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    private lazy var btnScanBarCode: UIButton = { [weak self] in
        let btn = makeAFunctionalButtonFromAwesomeFont(name: .barcode, leadingInset: 100, topInset: 100, cornerRadius: 0)
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        btn.addTarget(self, action: #selector(actionScanBarCode), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnEditSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionEditSave))
    private lazy var btnCreateSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionCreateSave))
    
    init(book: RealmBook) {
        self.book = book
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadHeaderView()
    }
}

private extension CreateBookViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = creating ? btnCreateSave : btnEditSave
        title = creating ? "添加书籍" : "编辑书籍信息"
    }
    
    func setupSubviews() {
        headerView.addSubview(btnScanBarCode)
        btnScanBarCode.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        setupForm()
    }
    
    func setupForm() {
        
        let nameInfoSection = Section("书籍信息")
        
        nameInfoSection <<< TextRow() {
            $0.tag = "isbn"
            $0.title = "ISBN"
            $0.value = ""
        }
        
        nameInfoSection <<< TextRow() {
            $0.tag = "name"
            $0.title = "书籍原名称"
            $0.value = ""
            $0.add(rule: RuleRequired(msg: "名称不能为空", id: nil))
        }
        
        nameInfoSection <<< TextRow() {
            $0.tag = "localeName"
            $0.title = "书籍翻译名称"
            $0.value = ""
        }
        
        form +++ nameInfoSection
        
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "作家们", footer: "") { (section) in
            section.tag = "authors"
            section.addButtonProvider = { s in
                let buttonRow = ButtonRow() {
                    $0.title = "关联作家"
                }
                buttonRow.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .left
                })
                return buttonRow
            }
            section.multivaluedRowToInsertAt = { index in
                return EurekaLabelValueRow<RealmAuthor>() {
                    $0.cellUpdate({ (cell, row) in
                        cell.textLabel?.text = row.value?.label ?? "选择一个作家"
                        cell.detailTextLabel?.text = row.value?.info?["localeName"] as? String ?? ""
                    })
                }
            }
        }
        
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "翻译家们", footer: "") { (section) in
            section.tag = "translators"
            section.addButtonProvider = { s in
                let buttonRow = ButtonRow() {
                    $0.title = "关联翻译家"
                }
                buttonRow.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .left
                })
                return buttonRow
            }
            section.multivaluedRowToInsertAt = { index in
                return EurekaLabelValueRow<RealmTranslator>() {
                    $0.cellUpdate({ (cell, row) in
                        cell.textLabel?.text = row.value?.label ?? "选择一个翻译家"
                        cell.detailTextLabel?.text = row.value?.info?["localeName"] as? String ?? ""
                    })
                }
            }
        }
        
        let digestRelatedSection = Section("出版社")
        digestRelatedSection <<< TextRow() {
            $0.tag = "publisher"
            $0.title = "出版社"
            $0.value = ""
        }
        form +++ digestRelatedSection
    }
    
    func reloadHeaderView() {
        headerView.height = HeaderHeight
        tableView.tableHeaderView = headerView
    }
}

private extension CreateBookViewController {
    func selectAuthorsComplete(authors: [RealmAuthor]) {
        guard let newAuthros = authors.first else { return }
        var selectedAuthors = form.values()["authors"] as? [RealmAuthor] ?? []
        selectedAuthors.append(newAuthros)
        form.setValues(["authors": selectedAuthors])
    }
}

private extension CreateBookViewController {
    @objc func actionScanBarCode() {
    }
    
    @objc func actionEditSave() {
        guard putFormValuesToModel() else { return }
    }
    
    @objc func actionCreateSave() {
        guard putFormValuesToModel() else { return }
        
        guard book.save() else {
            let alert = UIAlertController(title: "提示", message: "保存失败", defaultActionButtonTitle: "确定", tintColor: .black)
            navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let values = form.values()
        let authors = values["authors"] as? [EurekaLabelValueModel] ?? []
        let translators = values["translators"] as? [EurekaLabelValueModel] ?? []
        let authorIds: [String] =  authors.map{ $0.value }.duplicatesRemoved()
        let translatorIds: [String] = translators.map{ $0.value }.duplicatesRemoved()
        
        do {
            let objects = RealmAuthor.objectsForPrimaryKeys(of: RealmAuthor.self, keys: authorIds)
            try objects?.forEach { (object) in
                print(object.name)
                try Realm().write {
                    object.books.append(book)
                }
            }
            
            let os = RealmTranslator.objectsForPrimaryKeys(of: RealmTranslator.self, keys: translatorIds)
            try os?.forEach { (object) in
                print(object.name)
                try Realm().write {
                    object.books.append(book)
                }
            }
        } catch {
            let alert = UIAlertController(title: "提示", message: "保存失败", defaultActionButtonTitle: "确定", tintColor: .black)
            navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func putFormValuesToModel() -> Bool {
        view.endEditing(true)
        
        let errors = form.validate()
        guard errors.isEmpty else {
            navigationController?.present(UIAlertController(title: "提示", message: errors.first!.msg, defaultActionButtonTitle: "确定", tintColor: .black), animated: true, completion: nil)
            return false
        }
        
        let values = form.values()
        book.isbn = (values["isbn"] as? String ?? "").trimmed
        book.name = (values["name"] as? String ?? "").trimmed
        book.localeName = (values["localeName"] as? String ?? "").trimmed
        book.publisher = (values["publisher"] as? String ?? "").trimmed
        
        return true
    }
}
