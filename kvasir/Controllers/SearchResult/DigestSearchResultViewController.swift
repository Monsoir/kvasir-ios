//
//  SearchResultViewController.swift
//  kvasir
//
//  Created by Monsoir on 6/6/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import SnapKit
import RealmSwift

enum SearchType {
    case sentence
    case paragraph
}

class DigestSearchResultViewController: UIViewController, Configurable {
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = TextListTableViewCell.height
        view.backgroundColor = Color.init(hexString: ThemeConst.secondaryBackgroundColor)
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private lazy var sentenceCoordinator: DigestSearchResultCoordinator<RealmSentence> = { [unowned self] in
        let coordinator = DigestSearchResultCoordinator<RealmSentence>()
        coordinator.initialHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                self.reloadView(likeInitial: false)
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifictions) in
            MainQueue.async {
                guard let self = self else { return }
                self.tableView.msr.updateRows(deletions: deletions, insertions: insertions, modifications: modifictions)
            }
        }
        coordinator.errorHandler = { _ in
            MainQueue.async {
                Bartendar.handleSorryAlert(on: nil)
            }
        }
        return coordinator
    }()
    private lazy var paragraphCoordinator: DigestSearchResultCoordinator<RealmParagraph> = { [unowned self] in
        let coordinator = DigestSearchResultCoordinator<RealmParagraph>()
        coordinator.initialHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                self.reloadView(likeInitial: false)
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifictions) in
            MainQueue.async {
                guard let self = self else { return }
                self.tableView.msr.updateRows(deletions: deletions, insertions: insertions, modifications: modifictions)
            }
        }
        coordinator.errorHandler = { _ in
            MainQueue.async {
                Bartendar.handleSorryAlert(on: nil)
            }
        }
        return coordinator
    }()
    private var results: Any? {
        switch searchType {
        case .sentence:
            return sentenceCoordinator.results
        case .paragraph:
            return paragraphCoordinator.results
        }
    }
    private var searchType = SearchType.sentence
    
    private var didSearchSomething = false
    
    private var realNavigationController: UINavigationController? {
        return (configuration["navigationController"] as? UINavigationController) ?? self.navigationController
    }
    var configuration: Configurable.Configuration
    required init(configuration: Configurable.Configuration = [:]) {
        self.configuration = configuration
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
        setupSubviews()
    }
}

private extension DigestSearchResultViewController {
    func setupSubviews() {
        fixSpaceBetween()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func fixSpaceBetween() {
        // 修复当 table view 嵌在 search view controller 中，有巨大空白间隔的问题
        // https://stackoverflow.com/a/52135433/5211544
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func reloadView(likeInitial: Bool = true) {
        MainQueue.async {
            self.tableView.reloadData()
            self.reloadBackgroundView(likeInitial: likeInitial)
        }
    }
    
    func reloadBackgroundView(likeInitial: Bool = true) {
        if likeInitial {
            self.tableView.backgroundView = nil
            return
        }
        
        switch self.searchType {
        case .sentence:
            if let results = results as? Results<RealmSentence>, results.count > 0 {
                self.tableView.backgroundView = nil
                return
            }
        case .paragraph:
            if let results = results as? Results<RealmParagraph>, results.count > 0 {
                self.tableView.backgroundView = nil
                return
            }
        }
        self.tableView.backgroundView = CollectionTypeEmptyBackgroundView(title: "没有查到数据 -_-||", position: .upper, customFactor: 0.5)
    }
    
    func updateVisibleCellsInTableView(_ tableView: UITableView, accordingTo digestIds: Set<String>) {
        MainQueue.async {
            // 只更新可见的 cell
            guard let visibleCellIndexes = tableView.indexPathsForVisibleRows else { return }
            let updatingIndexes = visibleCellIndexes.filter { (ele) -> Bool in
                switch self.searchType {
                case .sentence:
                    guard let results = self.results as? Results<RealmSentence> else { return false }
                    return digestIds.contains(results[ele.row].id)
                case .paragraph:
                    guard let results = self.results as? Results<RealmParagraph> else { return false }
                    return digestIds.contains(results[ele.row].id)
                }
            }
            tableView.beginUpdates()
            tableView.reloadRows(at: updatingIndexes, with: .none)
            tableView.endUpdates()
        }
    }
}

extension DigestSearchResultViewController {
    func reloadData(of type: SearchType, keyword: String) {
        searchType = type
        restore()
        guard !keyword.isEmpty else { return }
        switch type {
        case .sentence:
            sentenceCoordinator.setupQuery(by: keyword)
        case .paragraph:
            paragraphCoordinator.setupQuery(by: keyword)
        }
        self.didSearchSomething = true
    }
    
    func restore() {
        guard didSearchSomething else  { return }
        
        sentenceCoordinator.clearResults()
        sentenceCoordinator.reclaim()
        
        paragraphCoordinator.clearResults()
        paragraphCoordinator.reclaim()
        
        reloadView()
    }
}

// MARK: - UITableViewDataSource
extension DigestSearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 加以判断，避免不必要的类型转换和初始化
        guard didSearchSomething else { return 0 }
        
        switch searchType {
        case .sentence:
            guard let results = results as? Results<RealmSentence> else { return 0 }
            return results.count
        case .paragraph:
            guard let results = results as? Results<RealmParagraph> else { return 0 }
            return results.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TextListTableViewCell?
        
        switch searchType {
        case .sentence:
            guard let digest = (results as? Results<RealmSentence>)?[indexPath.row] else { return UITableViewCell() }
            if let _ = digest.book?.hasImage {
                cell = tableView.dequeueTextListReusableCell(
                    withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon),
                    withImage: true
                )
                cell?.thumbnail = digest.book?.thumbnailImage ?? ""
            } else {
                cell = tableView.dequeueTextListReusableCell(
                    withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon),
                    withImage: false
                )
            }
            cell?.title = digest.title
            cell?.bookName = digest.book?.name
            cell?.recordUpdatedDate = digest.updateAtReadable
            return cell!
        case .paragraph:
            guard let digest = (results as? Results<RealmParagraph>)?[indexPath.row] else { return UITableViewCell() }
            if let _ = digest.book?.hasImage {
                cell = tableView.dequeueTextListReusableCell(
                    withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon),
                    withImage: true
                )
                cell?.thumbnail = digest.book?.thumbnailImage ?? ""
            } else {
                cell = tableView.dequeueTextListReusableCell(
                    withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon),
                    withImage: false
                )
            }
            cell?.title = digest.title
            cell?.bookName = digest.book?.name
            cell?.recordUpdatedDate = digest.updateAtReadable
//            cell?.tagColors = (digest as! RealmParagraph).tags.map { $0.color }
            return cell!
        }
    }
}

// MARK: - UITableViewDelegate
extension DigestSearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchType {
        case .sentence:
            guard let digest = (results as? Results<RealmSentence>)?[indexPath.row] else { return }
            KvasirNavigator.push(KvasirURL.detailSentence.url(with: ["id": digest.id]), context: nil, from: realNavigationController, animated: true)
        case .paragraph:
            guard let digest = (results as? Results<RealmParagraph>)?[indexPath.row] else { return }
            KvasirNavigator.push(KvasirURL.detailParagraph.url(with: ["id": digest.id]), context: nil, from: realNavigationController, animated: true)
        }
    }
}

private extension UITableView {
    func dequeueTextListReusableCell(withIdentifier identifier: String, withImage: Bool) -> TextListTableViewCell? {
        if withImage {
            var cell = dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: identifier,
                    needThumbnail: true
                )
            }
            return cell as? TextListTableViewCell
        } else {
            var cell = dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: identifier
                )
            }
            return cell as? TextListTableViewCell
        }
    }
}
