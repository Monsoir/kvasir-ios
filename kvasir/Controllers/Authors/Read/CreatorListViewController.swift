//
//  AuthorListViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift
import SwifterSwift

class CreatorListViewController<Creator: RealmCreator>: ResourceListViewController, UITableViewDataSource, UITableViewDelegate {
    typealias SelectCompletion =  ((_ creators: [Creator]) -> Void)
    
    private lazy var coordinator = CreatorListCoordinator<Creator>()
    private var results: Results<Creator>? {
        get {
            return coordinator.results
        }
    }
    
    private var selectCompletion: SelectCompletion?
    private var preSelectionIds: [String] = []
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = 50
        view.dataSource = self
        view.delegate = self
        view.tableFooterView = UIView()
        return view
    }()
    
    init(with configuration: [String: Any], selectCompletion completion: SelectCompletion? = nil, preSelections: [Creator]? = nil) {
        super.init(with: configuration)
        self.selectCompletion = completion
        if let selections = preSelections {
            self.preSelectionIds = selections.map({ (creator) -> String in
                return creator.id
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        coordinator.reclaim()
        debugPrint("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        configureCoordinator()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier())
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: BookListTableViewCell.reuseIdentifier())
        }
        
        guard let creator = results?[indexPath.row] else { return UITableViewCell() }
        cell?.textLabel?.text = [creator.name, creator.localeName].joined(separator: "/")
        cell?.textLabel?.text = {
            var texts = [creator.name]
            if !creator.localeName.isEmpty {
                texts.append(creator.localeName)
            }
            return texts.joined(separator: "/")
        }()
        cell?.accessoryType = modifyable ? .disclosureIndicator : .none // 可编辑时看作为查看列表而不是进行选择
        
        var detail = ""
        switch creator {
        case is RealmAuthor:
            detail = "关联书籍：\((creator as! RealmAuthor).books.count)"
        case is RealmTranslator:
            detail = "关联书籍：\((creator as! RealmTranslator).books.count)"
        default:
            break
        }
        cell?.detailTextLabel?.text = detail
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return modifyable
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let entity = results?[indexPath.row] else { return }
            
            let sheet = UIAlertController(title: "确定删除\(Creator.toHuman())", message: entity.name, preferredStyle: .actionSheet)
            sheet.addAction(title: "删除", style: .destructive, isEnabled: true) { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.doDeleteAuthor(entity: entity)
            }
            sheet.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
            navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
    
    private func doDeleteAuthor(entity: Creator) {
        coordinator.delete(a: entity, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let creator = results?[indexPath.row] else { return }
        if !modifyable, !preSelectionIds.contains(creator.id) {
            selectCompletion?([creator])
            navigationController?.popViewController()
        }
        
        switch creator {
        case is RealmTranslator:
            KvasirNavigator.push(KvasirURL.booksOfATranslator.url(with: ["id": creator.id]), context: nil, from: navigationController, animated: true)
        case is RealmAuthor:
            KvasirNavigator.push(KvasirURL.booksOfAnAuthor.url(with: ["id": creator.id]), context: nil, from: navigationController, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func actionCreate() {
        let vc = CreateCreatorViewController<Creator>(model: Creator(), creating: true)
        let nc = UINavigationController(rootViewController: vc)
        navigationController?.present(nc, animated: true, completion: nil)
    }
}

private extension CreatorListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))
        title = configuration["title"] as? String ?? ""
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBackgroundIfNeeded() {
        guard let count = results?.count, count <= 0 else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = CollectionTypeEmptyBackgroundView(title: "右上角添加一个\(Creator.toHuman())吧", position: .upper)
    }

    func configureCoordinator() {
        coordinator.initialLoadHandler = { [weak self] _ in
            MainQueue.async {
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
                strongSelf.setupBackgroundIfNeeded()
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifications) in
            MainQueue.async {
                guard let strongSelf = self else { return }
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.deleteRows(at: deletions, with: .fade)
                strongSelf.tableView.insertRows(at: insertions, with: .fade)
                strongSelf.tableView.reloadRows(at: modifications, with: .fade)
                strongSelf.tableView.endUpdates()
                strongSelf.setupBackgroundIfNeeded()
            }
        }
        coordinator.errorHandler = nil
        coordinator.setupQuery()
    }
}

typealias AuthorListViewController = CreatorListViewController<RealmAuthor>
typealias TranslatorListViewController = CreatorListViewController<RealmTranslator>
