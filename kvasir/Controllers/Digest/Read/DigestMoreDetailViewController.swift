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

private let SectionTitles = [
    "书名",
    "作者",
    "译者",
    "出版社",
    "摘录页码",
    "上次修改时间",
]

class DigestMoreDetailViewController<Digest: RealmWordDigest>: UnifiedViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var coordinator: DigestDetailCoordinator<Digest>!
    private var entity: Digest? {
        get {
            return coordinator.entity
        }
    }
    
    private lazy var infoTableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.register(
            DigestDetailTableViewCell.self,
            forCellReuseIdentifier: DigestDetailTableViewCell.reuseIdentifier()
        )
        view.tableFooterView = UIView()
        return view
    }()
    
    init(digestId: String) {
        self.coordinator = DigestDetailCoordinator(digestId: digestId)
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
            guard success else {
                Bartendar.handleSimpleAlert(title: "提示", message: "没有找到数据", on: self?.navigationController)
                return
            }
            guard let self = self else { return }
            MainQueue.async {
                self.infoTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let cell = configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: entity.book?.name ?? "", more: true)
            return cell
        case 1:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: entity.book?.createAuthorsReadable("\n") ?? "")
        case 2:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: entity.book?.createTranslatorReadabel("\n") ?? "")
        case 3:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: entity.book?.publisher ?? "")
        case 4:
            let cell = configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: "\(entity.pageIndex >= 0 ? "\(entity.pageIndex)" : "")", more: true)
            return cell
        case 5:
            return configureCell(DigestDetailTableViewCell.reuseIdentifier(), indexPath: indexPath, label: SectionTitles[indexPath.row], value: entity.updateAtReadable)
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showBookList()
        case 4:
            showPageIndexEdit()
        default:
            return
        }
    }
}

extension DigestMoreDetailViewController {
    private func setupSubviews() {
        view.addSubview(infoTableView)
        
        infoTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureCoordinator() {
        coordinator.reload = { [weak self] _ in
            guard let self = self else { return }
            MainQueue.async {
                self.infoTableView.reloadData()
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
    }
    
    private func showBookList() {
        MainQueue.async {
            let vc = BookListViewController(with: ["editable": false]) { [weak self] (book, currentVC) in
                guard let self = self else { return }
                self.coordinator?.updateBookRef(book: book, completion: { (success) in
                    DispatchQueue.main.async {
                        guard success else {
                            Bartendar.handleSorryAlert(message: "修改失败", on: self.navigationController)
                            return
                        }
                        
                        currentVC?.dismiss(animated: true, completion: nil)
                    }
                })
            }
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
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
}
