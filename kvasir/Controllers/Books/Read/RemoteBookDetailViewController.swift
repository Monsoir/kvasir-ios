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

class RemoteBookDetailViewController: UIViewController {
    
    private var coordinator: RemoteBookCoordinator!
    private var dataToDisplay = [(label: String, value: Any)]()
    
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
    
    init(with coordinator: RemoteBookCoordinator) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
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
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadHeaderView()
    }
    
    private func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = itemChooseIt
        title = coordinator.title
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupData() {
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
        dataToDisplay = data
    }
    
    private func reloadHeaderView() {
        headerView.height = CGFloat(RemoteBookDetailHeader.height)
        headerView.width = tableView.width
        headerView.payload = coordinator.payloadForHeader
        tableView.tableHeaderView = headerView
    }
    
    @objc private func actionChooseIt() {
        HUD.show(.labeledProgress(title: "创建中", subtitle: nil))
        coordinator.batchCreate { (success, message) in
            MainQueue.async { [weak self] in
                HUD.hide()
                guard success else {
                    Bartendar.handleSorryAlert(message: message ?? "", on: nil)
                    return
                }
                if message != nil {
                    HUD.flash(.label(message ?? ""), delay: 1.5)
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension RemoteBookDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row == 0 else { return }
        let vc = PlainTextViewController()
        vc.navigationTitle = "简介"
        vc.content = coordinator.summary
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RemoteBookDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DigestDetailTableViewCell.reuseIdentifier(), for: indexPath) as! DigestDetailTableViewCell
        let data = dataToDisplay[indexPath.row]
        cell.label = data.label
        cell.value = "\(data.value)"
        
        if indexPath.row == 0 {
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
