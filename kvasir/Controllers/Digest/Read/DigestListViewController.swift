//
//  TextListViewController.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import RealmSwift

class DigestListViewController: UnifiedViewController, UITableViewDataSource, UITableViewDelegate, Configurable {

    private var coordinator: DigestListCoordinator!
    private var results: Results<RealmWordDigest>? {
        return coordinator.results
    }
    
    private var configuration: [String: Any]
    
    /// 是否可以添加新的 Digest, 默认为 false
    private var canAdd: Bool {
        return configuration["canAdd"] as? Bool ?? false
    }
    private var category: RealmWordDigest.Category {
        return configuration[#keyPath(RealmWordDigest.category)] as? RealmWordDigest.Category ?? RealmWordDigest.Category.sentence
    }
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(TextListTableViewCell.height)
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        return view
    }()
    
    private var navigationTitle: String {
        if let t = configuration["title"] as? String {
            return t
        }
        return coordinator.bookName.isEmpty ? category.toHuman : "\(coordinator.bookName)的\(category.toHuman)"
    }
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        coordinator = DigestListCoordinator(configuration: configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        coordinator.reclaim()
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        configureCoordinator()
    }
    
    @objc func actionCreate() {
        let dict = [
            RealmWordDigest.Category.sentence.toMachine: KvasirURL.newSentence.url(),
            RealmWordDigest.Category.paragraph.toMachine: KvasirURL.newParagraph.url(),
        ]
        KvasirNavigator.present(
            dict[category.toMachine]!,
            context: nil,
            wrap: UINavigationController.self,
            from: AppRootViewController,
            animated: true,
            completion: nil
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TextListTableViewCell?
        guard let digest = results?[indexPath.row] else { return UITableViewCell() }
        
        if let _ = digest.book?.hasImage {
            cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon)) as? TextListTableViewCell
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon),
                    needThumbnail: true
                )
            }
            cell?.thumbnail = digest.book?.thumbnailImage ?? ""
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon)) as? TextListTableViewCell
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon
                )
            }
        }
        
        cell?.title = digest.title
        cell?.bookName = digest.book?.name
        cell?.recordUpdatedDate = digest.updateAtReadable
        cell?.tagColors = digest.tags.map { $0.color }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let digest = results?[indexPath.row] else { return }
        switch category {
        case .sentence:
            KvasirNavigator.push(KvasirURL.detailSentence.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        case .paragraph:
            KvasirNavigator.push(KvasirURL.detailParagraph.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        }
    }
}

private extension DigestListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        
        if canAdd {
            navigationItem.rightBarButtonItem = makeBarButtonItem(.plus, target: self, action: #selector(actionCreate))
        }
        title = navigationTitle
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureCoordinator() {
        coordinator.initialHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                self.reload()
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifictions) in
            MainQueue.async {
                guard let self = self else { return }
                self.tableView.msr.updateRows(deletions: deletions, insertions: insertions, modifications: modifictions)
                self.reloadBackgroundView()
            }
        }
        coordinator.errorHandler = { _ in
            MainQueue.async {
                Bartendar.handleSorryAlert(on: nil)
            }
        }
        coordinator.tagUpdateHandler = { [weak self] (updatedDigestIds, digestType) in
            guard let self = self else { return }
            self.updateVisibleCellsInTableView(self.tableView, accordingTo: updatedDigestIds)
        }
        coordinator.setupQuery()
    }
    
    func reloadBackgroundView() {
        self.tableView.backgroundView = self.results?.count ?? 0 <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有\(category.toHuman)的摘录", position: .upper) : nil
    }
    
    func reload() {
        MainQueue.async {
            self.reloadBackgroundView()
            self.title = self.navigationTitle
            self.tableView.reloadData()
        }
    }
    
    func updateVisibleCellsInTableView(_ tableView: UITableView, accordingTo digestIds: Set<String>) {
        MainQueue.async {
            // 只更新可见的 cell
            guard let visibleCellIndexes = tableView.indexPathsForVisibleRows else { return }
            let updatingIndexes = visibleCellIndexes.filter { (ele) -> Bool in
                return digestIds.contains((self.results?[ele.row].id ?? ""))
            }
            tableView.beginUpdates()
            tableView.reloadRows(at: updatingIndexes, with: .none)
            tableView.endUpdates()
        }
    }
}
