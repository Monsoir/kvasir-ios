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
import PKHUD

private let HeaderHeight = 150.0 as CGFloat

class CreateBookViewController: FormViewController {
    
    private var creating = true
    private var book: RealmBook
    private lazy var coordinator = CreateBookCoordinator(entity: self.book)
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    private lazy var btnCreateSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionCreateSave))
    
    init(book: RealmBook) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
    }
}

private extension CreateBookViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = btnCreateSave
        title = "添加书籍"
    }
    
    func setupSubviews() {
        setupForm()
    }
    
    func setupForm() {
        
        let nameInfoSection = Section("书籍信息")
        
        nameInfoSection <<< TextRow() {
            $0.tag = "isbn13"
            $0.title = "ISBN13"
            $0.value = ""
            $0.add(rule: RuleClosure<String> { rawValue in
                guard let value = rawValue, !value.isEmpty else {
                    return nil
                }
                // ISBN 不为空的情况才检验是否输入符合规范
                if !value.msr.isISBN13 {
                    return ValidationError(msg: "不符合规范的 ISBN13")
                }
                return nil
            })
        }
        
        nameInfoSection <<< TextRow() {
            $0.tag = "isbn10"
            $0.title = "ISBN10"
            $0.value = ""
            $0.add(rule: RuleClosure<String> { rawValue in
                guard let value = rawValue, !value.isEmpty else {
                    return nil
                }
                // ISBN 不为空的情况才检验是否输入符合规范
                if !value.msr.isISBN10 {
                    return ValidationError(msg: "不符合规范的 ISBN10")
                }
                return nil
            })
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
    @objc func actionCreateSave() {
        view.endEditing(true)
        
        let errors = form.validate()
        guard errors.isEmpty else {
            Bartendar.handleSimpleAlert(title: "提示", message: errors.first!.msg, on: self.navigationController)
            return
        }
        
        let values = form.values()
        let authorIds = (values["authors"] as? [EurekaLabelValueModel] ?? []).map { $0.value }.duplicatesRemoved()
        let translatorIds = (values["translators"] as? [EurekaLabelValueModel] ?? []).map { $0.value }.duplicatesRemoved()
        
        let postInfo = values.merging(["authorIds": authorIds, "translatorIds": translatorIds]) { (current, new) -> Any? in
            return new
        }
        
        do {
            try coordinator.post(info: postInfo)
        } catch {
            Bartendar.handleSorryAlert(on: self.navigationController)
            return
        }
        
        coordinator.create { (success, message) in
            guard success else {
                Bartendar.handleSorryAlert(message: "保存失败", on: self.navigationController)
                return
            }
            
            MainQueue.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func actionSearch(_ isbn: String?) {
        HUD.show(.progress)
        coordinator.queryFromRemote(isbn: isbn) { (success, data, errorMsg) in
            guard success else {
                MainQueue.async {
                    HUD.flash(.labeledError(title: errorMsg, subtitle: nil), onView: self.view, delay: 1.5, completion: nil)
                }
                return
            }
            MainQueue.async {
                let remoteCoordinator = RemoteBookDetailCoordinator(with: data ?? [:])
                let vc = BookDetailViewController(with: remoteCoordinator)
                let nc = UINavigationController(rootViewController: vc)
                self.navigationController?.present(nc, animated: true, completion: {
                    HUD.hide()
                })
            }
        }
    }
}
