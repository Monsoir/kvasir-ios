//
//  DigestMoreDetailViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import PKHUD

private let BasicInfoSectionTitles = [
    "书名",
    "作者",
    "译者",
    "出版社",
    "摘录页码",
    "上次修改时间",
]

private let TableSectionTitles = [
    "基本信息", "标签信息",
]

private let FooterIdentifier = "footer"

class DigestMoreDetailViewController<Digest: RealmWordDigest>: UnifiedViewController, UITableViewDataSource, UITableViewDelegate, Configurable {
    
    private lazy var coordinator = DigestDetailCoordinator<Digest>(configuration: self.configuration)
    private lazy var tagCoordinator = DigestDetailTagCoordinator<Digest>(configuration: self.configuration.merging(["tagSection": 1], uniquingKeysWith: { (_, new) -> Any in
        return new
    }))
    private let configuration: Configuration
    private var entity: Digest? {
        get {
            return coordinator.entity
        }
    }
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .grouped)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.register(DigestDetailTableViewCell.self, forCellReuseIdentifier: DigestDetailTableViewCell.reuseIdentifier())
        view.register(TopListTableViewHeaderPlain.self, forHeaderFooterViewReuseIdentifier: TopListTableViewHeaderPlain.reuseIdentifier())
        view.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: FooterIdentifier)
        view.separatorColor = .white
        view.tableFooterView = UIView()
        return view
    }()
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        
        coordinator.reclaim()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "详细"
        setupSubviews()
        configureCoordinator()
        coordinator.queryOne { [weak self] (success, entity) in
            guard let self = self else { return }
            guard success else {
                Bartendar.handleSimpleAlert(title: "提示", message: "没有找到数据", on: self.navigationController)
                return
            }
            MainQueue.async {
                self.tableView.reloadData()
            }
        }
        tagCoordinator.setupQuery(for: 1)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return BasicInfoSectionTitles.count
        case 1:
            return tagCoordinator.results?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return cellForBasicInfoOf(tableView: tableView, at: indexPath)
        case 1:
            return cellForTagOf(tableView: tableView, at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 48
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TopListTableViewHeaderActionable.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeaderPlain.reuseIdentifier()) as? TopListTableViewHeaderPlain else { return nil }
        header.title = TableSectionTitles[section]
        header.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: FooterIdentifier)
        footer?.contentView.backgroundColor = .clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                showBookList()
            case 4:
                showPageIndexEdit()
            default:
                return
            }
        case 1:
            updateTag(at: indexPath)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DigestMoreDetailViewController {
    private func setupSubviews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureCoordinator() {
        coordinator.reload = { [weak self] _ in
            guard let self = self else { return }
            MainQueue.async {
                self.tableView.reloadData()
            }
        }
        coordinator.errorHandler = { [weak self] msg in
            guard let strongSelf = self else { return }
            MainQueue.async {
                strongSelf.navigationController?.popToRootViewController(animated: true)
                Bartendar.handleSorryAlert(message: msg, on: nil)
            }
        }
        coordinator.entityDeleteHandler = { [weak self] in
            guard let strongSelf = self else { return }
            MainQueue.async {
                strongSelf.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        tagCoordinator.initialHandler = { [weak self] _ in
            guard let self = self else { return }
            self.coordinator.assembleTagIds()
            MainQueue.async {
                self.tableView.reloadData()
            }
        }
        tagCoordinator.updateHandler = { [weak self] (deletions, insertions, modifications) in
            guard let self = self else { return }
            self.coordinator.assembleTagIds()
            MainQueue.async {
                self.tableView.msr.updateRows(deletions: deletions, insertions: insertions, modifications: modifications, with: .automatic)
            }
        }
        tagCoordinator.errorHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                Bartendar.handleSorryAlert(on: self.navigationController)
            }
        }
    }
    
    private func showBookList() {
        MainQueue.async {
            let config: Configurable.Configuration = [
                "editable": false,
                "completion": { [weak self] (book: RealmBook, vc: UIViewController) in
                    guard let self = self else { return }
                    self.coordinator.updateBookRef(book: book, completion: { [weak self] (success) in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            guard success else {
                                Bartendar.handleSorryAlert(message: "修改失败", on: self.navigationController)
                                return
                            }
                            
                            vc.navigationController?.popViewController()
                        }
                    })
                },
            ]
            KvasirNavigator.push(KvasirURL.selectBooks.url(), context: config)
        }
    }
    
    func showPageIndexEdit() {
        MainQueue.async {
            let completion: FieldEditCompletion = { [weak self] (newValue, vc) in
                guard let self = self else { return }
                MainQueue.async {
                    let putInfo = [
                        "pageIndex": newValue as? Int ?? -1
                    ]
                    do {
                        try self.coordinator.put(info: putInfo)
                    } catch let e as ValidateError {
                        Bartendar.handleTipAlert(message: e.message, on: self.navigationController)
                        return
                    } catch {
                        Bartendar.handleSorryAlert(on: self.navigationController)
                        return
                    }
                    self.coordinator.update(completion: { (success) in
                        guard success else {
                            Bartendar.handleSorryAlert(message: "更新失败", on: self.navigationController)
                            return
                        }
                        MainQueue.async {
                            vc?.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
            let validateErrorHandler: FieldEditValidatorHandler = { [weak self] messages in
                guard let self = self else { return }
                Bartendar.handleTipAlert(message: messages.first ?? "", on: self.navigationController)
                return
            }
            
            let info: [String: Any?] = [
                FieldEditInfoPreDefineKeys.title: "摘录页码",
                FieldEditInfoPreDefineKeys.oldValue: {
                    guard let pageIndex = self.entity?.pageIndex else {
                        return ""
                    }
                    return pageIndex >= 0 ? "\(pageIndex)" : ""
                }(),
                FieldEditInfoPreDefineKeys.completion: completion,
                FieldEditInfoPreDefineKeys.validateErrorHandler: validateErrorHandler,
                "greaterOrEqualThan": 0,
            ]
            let vc = FieldEditFactory.createAFieldEditController(of: .digit, editInfo: info)
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        }
    }
    
    func updateTag(at indexPath: IndexPath) {
        guard let tag = tagCoordinator.results?[indexPath.row], let entityId = entity?.id else { return }
        
        do {
            try tagCoordinator.put(info: ["tagId": tag.id, "entityIds": [entityId]])
        } catch {}
        
        tagCoordinator.update { [weak self] (success) in
            guard let self = self else { return }
            if !success {
                MainQueue.async {
                    HUD.flash(.labeledError(title: "更改标签失败", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                }
            }
        }
    }
}

private extension DigestMoreDetailViewController {
    func cellForBasicInfoOf(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        func configureCell(_ identifier: String, indexPath: IndexPath, label: String, value: String, more: Bool = false) -> DigestDetailTableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DigestDetailTableViewCell
            cell.label = label
            cell.value = value
            cell.selectionStyle = .none
            cell.accessoryType = more ? .disclosureIndicator : .none
            return cell
        }
        
        guard let entity = entity else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            let cell = configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: entity.book?.name ?? "", more: true)
            return cell
        case 1:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: entity.book?.createAuthorsReadable("\n") ?? "")
        case 2:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: entity.book?.createTranslatorReadabel("\n") ?? "")
        case 3:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: entity.book?.publisher ?? "")
        case 4:
            let cell = configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: "\(entity.pageIndex >= 0 ? "\(entity.pageIndex)" : "")", more: true)
            return cell
        case 5:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: BasicInfoSectionTitles[indexPath.row], value: entity.updateAtReadable)
        default:
            return UITableViewCell()
        }
    }
    
    func cellForTagOf(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let tag = tagCoordinator.results?[indexPath.row] else { return UITableViewCell() }
        var cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier())
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.reuseIdentifier())
        }
        
        cell?.textLabel?.text = tag.name
        cell?.textLabel?.textColor = Color(hexString: tag.color)
        cell?.accessoryType = (coordinator.tagIdSet?.contains(tag.id) ?? false) ? .checkmark : .none
        return cell!
    }
}
