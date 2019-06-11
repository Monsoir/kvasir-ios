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
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = SearchResultTableViewCell.height
        view.backgroundColor = Color.init(hexString: ThemeConst.secondaryBackgroundColor)
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        view.keyboardDismissMode = .onDrag
        view.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier())
        return view
    }()
    
    private lazy var coordinator = DigestSearchResultCoordinator()
    
    private var results: [DigestSearchResult] {
        return coordinator.searchResults
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
            if results.count > 0 {
                self.tableView.backgroundView = nil
                return
            }
        case .paragraph:
            if results.count > 0 {
                self.tableView.backgroundView = nil
                return
            }
        }
        self.tableView.backgroundView = CollectionTypeEmptyBackgroundView(title: "没有查到数据 -_-||", position: .upper, customFactor: 0.5)
    }
}

extension DigestSearchResultViewController {
    func reloadData(of type: SearchType, keyword: String) {
        searchType = type
        coordinator.setupQuery(by: keyword, of: type) { [weak self] (success) in
            guard let self = self else { return }
            guard success else { return }
            
            self.coordinator.requestData(completion: { [weak self] (results) in
                guard let self = self else { return }
                MainQueue.async {
                    self.tableView.reloadData()
                }
            })
        }
        self.didSearchSomething = true
        
    }
    
    func restore(exit: Bool = false) {
        guard didSearchSomething else  { return }
        coordinator.cleanupForNext()
        
        reloadView()
        if exit {
            coordinator.reclaimThread()
        }
    }
}

// MARK: - UITableViewDataSource
extension DigestSearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 加以判断，避免不必要的类型转换和初始化
        guard didSearchSomething else { return 0 }
        
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier(), for: indexPath) as! SearchResultTableViewCell
        
        let attributes: StringAttributes = [
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Light", size: 24)!,
        ]
        let highlightedAttributes: StringAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
        ]
        
        var model: DigestSearchResult
        switch searchType {
        case .sentence:
            model = results[indexPath.row]
        case .paragraph:
            model = results[indexPath.row]
        }
        
        let title = NSMutableAttributedString(string: model.content, attributes: attributes)
        title.addAttributes(highlightedAttributes, range: NSRange(model.range, in: model.content))
        cell.attributedTitle = title
        cell.bookName = model.bookName
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DigestSearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = results[indexPath.row]
        switch searchType {
        case .sentence:
            KvasirNavigator.push(KvasirURL.detailSentence.url(with: ["id": model.id]), context: nil, from: realNavigationController, animated: true)
        case .paragraph:
            KvasirNavigator.push(KvasirURL.detailParagraph.url(with: ["id": model.id]), context: nil, from: realNavigationController, animated: true)
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
