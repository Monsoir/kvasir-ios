//
//  RemoteBookDetailViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import SnapKit
import PKHUD

private let DisplayTitles = [
    "简介", "原书名", "译者", "ISBN-13", "ISBN-10",
    "总页数", "装订", "价格", "出版社",
]

private let DisplayHeaderTitles = ["与我相关", "书籍信息"]

private let DisplayDigestTitles = [
    "句摘", "段摘",
]

class BookDetailViewController: UnifiedViewController {
    
    private var coordinator: BookDetailCoordinable!
    private var dataToDisplay = [(label: String, value: Any)]()
    private var loaded = false
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = BookListTableViewCell.height
        view.estimatedRowHeight = 200
        view.register(DigestDetailTableViewCell.self, forCellReuseIdentifier: DigestDetailTableViewCell.reuseIdentifier())
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        return view
    }()
    
    private lazy var headerView: RemoteBookDetailHeader = { [unowned self] in
        let width = self.view.width
        return RemoteBookDetailHeader(frame: CGRect(x: 0.0, y: 0.0, width: Double(width), height: RemoteBookDetailHeader.height))
    }()
    
    private lazy var itemChooseIt: UIBarButtonItem = UIBarButtonItem(title: "选中", style: .done, target: self, action: #selector(actionChooseIt))
    
    init(with coordinator: BookDetailCoordinable) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(self) deinit")
        coordinator.reclaim()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded {setupCoordinator()
            reloadData()
            if coordinator is RemoteBookDetailCoordinator {
                HUD.show(.progress, onView: navigationController?.view)
            }
            loaded = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadHeaderView()
    }
    
    private func setupNavigationBar() {
        setupImmersiveAppearance()
        if coordinator is RemoteBookDetailCoordinator {
            navigationItem.rightBarButtonItem = itemChooseIt
        }
        title = coordinator.title
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func reloadData() {
        // 与 DisplayTitles 顺序对应
        let values: [Any] = [
            coordinator.summary,
            coordinator.originTitle,
            coordinator.translators,
            coordinator.isbn13,
            coordinator.isbn10,
            coordinator.pages,
            coordinator.binding,
            coordinator.price,
            coordinator.publisher,
        ]
        let data = (DisplayTitles.enumerated().map { (index, ele) -> (String, Any) in
            return (ele, values[index])
        }).filter { (label, value) -> Bool in
            switch value {
            case is Int:
                return value as! Int > 0
            case is String:
                return !(value as! String).isEmpty
            default:
                return false
            }
        }
        title = coordinator.title
        dataToDisplay = data
        tableView.reloadData()
    }
    
    private func setupCoordinator() {
        if coordinator is LocalBookCoordinator {
            let c = coordinator as! LocalBookCoordinator
            c.reload = { [weak self] _ in
                guard let strongSelf = self else { return }
                MainQueue.async {
                    strongSelf.reloadData()
                }
            }
            c.entityDeleteHandler = { [weak self] in
                guard let strongSelf = self else { return }
                MainQueue.async {
                    HUD.flash(.label("书籍已被删除"), onView: nil, delay: 1.5, completion: nil)
                    strongSelf.navigationController?.popViewController()
                }
            }
            c.errorHandler = { msg in
                MainQueue.async {
                    HUD.flash(.labeledError(title: "出错了", subtitle: msg), onView: nil, delay: 1.5, completion: nil)
                }
            }
            c.query { [weak self] (success, entity, _) in
                guard success, let strongSelf = self else { return }
                MainQueue.async {
                    strongSelf.reloadData()
                    strongSelf.reloadHeaderView()
                }
            }
        }
        
        if coordinator is RemoteBookDetailCoordinator {
            let c = coordinator as! RemoteBookDetailCoordinator
            c.reload = { [weak self] _ in
                guard let strongSelf = self else { return }
                MainQueue.async {
                    strongSelf.reloadData()
                }
            }
            c.errorHandler = { [weak self] msg in
                MainQueue.async {
//                    HUD.flash(.labeledError(title: "出错了", subtitle: msg), onView: nil, delay: 1.5, completion: nil)
                    // 弹出 HUD 已在请求完成后统一处理了
                    guard let strongSelf = self else { return }
                    strongSelf.dismiss(animated: true, completion: nil)
                }
            }
            c.query { [weak self] (success, data, message) in
                guard success, let strongSelf = self else {
                    MainQueue.async { [weak self] in
                        HUD.flash(.labeledError(title: "出错了", subtitle: message ?? ""), onView: nil, delay: 1.5, completion: nil)
                        guard let innerStrongSelf = self else {
                            return
                        }
                        innerStrongSelf.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                MainQueue.async {
                    HUD.hide(animated: true)
                    strongSelf.reloadData()
                    strongSelf.reloadHeaderView()
                }
            }
        }
    }
    
    private func reloadHeaderView() {
        headerView.height = CGFloat(RemoteBookDetailHeader.height)
        headerView.width = tableView.width
        headerView.payload = coordinator.payloadForHeader
        tableView.tableHeaderView = headerView
    }
    
    @objc private func actionChooseIt() {
        guard coordinator is RemoteBookDetailCoordinator else { return }
        HUD.show(.labeledProgress(title: "创建中", subtitle: nil))
        (coordinator as! RemoteBookDetailCoordinator).batchCreate { (success, message) in
            MainQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                HUD.hide()
                guard success else {
                    Bartendar.handleSorryAlert(message: message ?? "", on: strongSelf.navigationController)
                    return
                }
                if message != nil {
                    HUD.flash(.label(message ?? ""), delay: 1.5)
                }
                strongSelf.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension BookDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if coordinator is RemoteBookDetailCoordinator && indexPath.section == 0 && indexPath.row == 0 ||
            coordinator is LocalBookCoordinator && indexPath.section == 1 && indexPath.row == 0 {
            guard !coordinator.mightAddedManully else { return }
            
            let vc = PlainTextViewController()
            vc.navigationTitle = "简介"
            vc.content = coordinator.summary
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if coordinator is LocalBookCoordinator && indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                KvasirNavigator.push(KvasirURL.sentencesOfBook.url(with: ["id": coordinator.id]))
            case 1:
                KvasirNavigator.push(KvasirURL.paragraphsOfBook.url(with: ["id": coordinator.id]))
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if coordinator is RemoteBookDetailCoordinator {
            return 0
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard coordinator is LocalBookCoordinator else { return nil }
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeaderActionable.reuseIdentifier())
        if header == nil {
            header = TopListTableViewHeaderActionable(reuseIdentifier: TopListTableViewHeaderActionable.reuseIdentifier(), actionable: false)
        }
        
        (header as! TopListTableViewHeaderActionable).title = DisplayHeaderTitles[section]
        header?.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        return header
    }
}

extension BookDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if coordinator is LocalBookCoordinator {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if coordinator is LocalBookCoordinator {
            if section == 0 {
                return DisplayDigestTitles.count
            }
        }
        return dataToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if coordinator is LocalBookCoordinator && indexPath.section == 0 {
            return cellForDigests(tableView: tableView, cellAtIndexPath: indexPath)
        }
        return cellForBookInfo(tableView: tableView, cellAtIndexPath: indexPath)
    }
    
    private func cellForDigests(tableView: UITableView, cellAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier())
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: UITableViewCell.reuseIdentifier())
        }
        cell?.textLabel?.text = DisplayDigestTitles[indexPath.row]
        cell?.detailTextLabel?.text = {
            switch indexPath.row {
            case 0:
                return "\((coordinator as! LocalBookCoordinator).sentencesCount)"
            case 1:
                return "\((coordinator as! LocalBookCoordinator).paragraphsCount)"
            default:
                return ""
            }
        }()
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    private func cellForBookInfo(tableView: UITableView, cellAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DigestDetailTableViewCell.reuseIdentifier(), for: indexPath) as! DigestDetailTableViewCell
        let data = dataToDisplay[indexPath.row]
        cell.label = data.label
        cell.value = "\(data.value)"
        
        if indexPath.row == 0 && !coordinator.mightAddedManully {
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            cell.maxLine = 4
        } else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
        
        return cell
    }
}
