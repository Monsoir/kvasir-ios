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

private let ContainerHeight = 50

class BookDetailViewController: UnifiedViewController, Configurable {
    
    private lazy var coordinator: BookDetailCoordinable = { [unowned self] in
        let mode = self.configuration["mode"] as? String ?? "local"
        if mode == "remote" {
            return RemoteBookDetailCoordinator(configuration: self.configuration)
        } else {
            return LocalBookDetailCoordinator(configuration: self.configuration)
        }
    }()
    private let configuration: Configuration
    private var createCompleteHandler: ((_: UIViewController) -> Void)? {
        return configuration["completion"] as? (_: UIViewController) -> Void
    }
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
        return RemoteBookDetailHeader(frame: CGRect(x: 0, y: 0, width: width, height: RemoteBookDetailHeader.height))
    }()
    
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        return view
    }()
    
    private lazy var btnDel: UIButton = { [unowned self] in
        let btn = makeAFunctionalButtonWith(title: "删除")
        btn.setTitleColor(.red, for: .normal)
        btn.addTarget(self, action: #selector(actionDel), for: .touchUpInside)
        return btn
    }()
    
    private lazy var itemChooseIt: UIBarButtonItem = UIBarButtonItem(title: "选中", style: .done, target: self, action: #selector(actionChooseIt))
    
    private var isLocal: Bool {
        return coordinator is LocalBookDetailCoordinator
    }
    
    private var isRemote: Bool {
        return coordinator is RemoteBookDetailCoordinator
    }
    
    required init(configuration: Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
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
        if !loaded {
            setupCoordinator()
            reloadData()
            if coordinator is RemoteBookDetailCoordinator {
                HUD.show(.progress, onView: navigationController?.view)
            }
            loaded = true
        }
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
        
        if isLocal {
            view.addSubview(buttonsContainer)
            buttonsContainer.addSubview(btnDel)
            
            tableView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(buttonsContainer.snp.top)
            }
            
            buttonsContainer.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(ContainerHeight)
                make.trailing.equalTo(buttonsContainer.snp.trailing)
            }
            
            btnDel.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview().offset(-20)
                make.centerY.equalToSuperview()
            }
        } else {
            tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        reloadHeaderView()
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
        reloadHeaderView()
        tableView.reloadData()
    }
    
    private func setupCoordinator() {
        if isLocal {
            let c = coordinator as! LocalBookDetailCoordinator
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
                    self.navigationController?.popViewController()
                }
            }
            c.query { [weak self] (success, entity, _) in
                guard success, let strongSelf = self else { return }
                MainQueue.async {
                    strongSelf.reloadData()
                }
            }
        }
        
        if isRemote {
            let c = coordinator as! RemoteBookDetailCoordinator
            c.reload = { [weak self] _ in
                guard let strongSelf = self else { return }
                MainQueue.async {
                    strongSelf.reloadData()
                }
            }
            c.errorHandler = { [weak self] msg in
                MainQueue.async {
                    // 弹出 HUD 已在请求完成后统一处理了
                    guard let strongSelf = self else { return }
                    strongSelf.dismiss(animated: true, completion: nil)
                }
            }
            c.query { [weak self] (success, data, message) in
                guard success, let strongSelf = self else {
                    MainQueue.async { [weak self] in
//                        HUD.flash(.labeledError(title: "出错了", subtitle: message ?? ""), onView: nil, delay: 1.5, completion: nil)
                        guard let self = self else {
                            return
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                MainQueue.async {
                    HUD.hide(animated: true)
                    strongSelf.reloadData()
                }
            }
        }
    }
    
    private func reloadHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.width, height: type(of: headerView).height)
        headerView.payload = coordinator.payloadForHeader
        tableView.tableHeaderView = headerView
    }
    
    @objc private func actionChooseIt() {
        guard coordinator is RemoteBookDetailCoordinator else { return }
        HUD.show(.labeledProgress(title: "创建中", subtitle: nil))
        (coordinator as! RemoteBookDetailCoordinator).batchCreate { [weak self] (success, message) in
            guard let self = self else { return }
            MainQueue.async {
                HUD.hide()
                guard success else {
                    Bartendar.handleSorryAlert(message: message ?? "", on: self.navigationController)
                    return
                }
                if message != nil {
                    HUD.flash(.label(message ?? ""), delay: 1.5)
                }
                self.createCompleteHandler?(self)
            }
        }
    }
    
    @objc private func actionDel() {
        if isLocal {
            let bookName = coordinator.title
            
            let alert = UIAlertController(title: "确定删除书籍？", message: bookName, preferredStyle: .alert)
            alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
            alert.addAction(title: "删除", style: .destructive, isEnabled: true) { [weak self] (_) in
                guard let self = self else { return }
                let c = self.coordinator as! LocalBookDetailCoordinator
                c.delete { (success) in
                    guard success else { return }
                    MainQueue.async {
                        HUD.flash(.label("\(bookName)已删除"), onView: nil, delay: 1.5)
                    }
                }
            }
            present(alert, animated: true, completion: nil)
        }
    }
}

extension BookDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if coordinator is RemoteBookDetailCoordinator && indexPath.section == 0 && indexPath.row == 0 ||
            coordinator is LocalBookDetailCoordinator && indexPath.section == 1 && indexPath.row == 0 {
            guard !coordinator.mightAddedManully else { return }
            
            let vc = PlainTextViewController()
            vc.navigationTitle = "简介"
            vc.content = coordinator.summary
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if coordinator is LocalBookDetailCoordinator && indexPath.section == 0 {
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
        guard coordinator is LocalBookDetailCoordinator else { return nil }
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
        if coordinator is LocalBookDetailCoordinator {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if coordinator is LocalBookDetailCoordinator {
            if section == 0 {
                return DisplayDigestTitles.count
            }
        }
        return dataToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if coordinator is LocalBookDetailCoordinator && indexPath.section == 0 {
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
                return "\((coordinator as! LocalBookDetailCoordinator).sentencesCount)"
            case 1:
                return "\((coordinator as! LocalBookDetailCoordinator).paragraphsCount)"
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
            cell.maxLine = 1
        }
        
        return cell
    }
}
