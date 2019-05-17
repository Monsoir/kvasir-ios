//
//  BookListViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift
import SwifterSwift
import PKHUD

typealias BookSelectCompletion = (_ book: RealmBook) -> Void

private let CellWithThumbnailIdentifier = BookListTableViewCell.reuseIdentifier(extra: "with-thumnbnail")
private let CellWithoutThumbnailIdentifier = BookListTableViewCell.reuseIdentifier(extra: "without-thumnbnail")

class BookListViewController: ResourceListViewController {
    
    private lazy var coordinator: BookListCoordinator = BookListCoordinator(with: self.configuration)
    private var results: Results<RealmBook>? {
        get {
            return coordinator.results
        }
    }

    var selectCompletion: BookSelectCompletion?
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = BookListTableViewCell.height
        view.estimatedRowHeight = 200
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        return view
    }()
    
    init(with configuration: [String: Any], selectCompletion: BookSelectCompletion? = nil) {
        super.init(with: configuration)
        self.selectCompletion = selectCompletion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        configureCoordinator()
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        coordinator.reclaim()
    }
}

private extension BookListViewController {
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
        coordinator.errorHandler = { [weak self] _ in
            MainQueue.async {
                guard let strongSelf = self else { return }
                Bartendar.handleSorryAlert(on: strongSelf.navigationController)
            }
        }
        coordinator.setupQuery()
    }
    
    func setupBackgroundIfNeeded() {
        guard let count = results?.count, count <= 0 else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = CollectionTypeEmptyBackgroundView(title: "还没有书籍的收集", position: .upper)
    }
}

extension BookListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let book = results?[indexPath.row] else { return UITableViewCell() }
        
        var cell: BookListTableViewCell?
        if book.hasImage {
            cell = tableView.dequeueReusableCell(withIdentifier: CellWithThumbnailIdentifier) as? BookListTableViewCell
            if cell == nil {
                cell = BookListTableViewCell(style: .default, reuseIdentifier: CellWithThumbnailIdentifier, needThumbnail: true)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: CellWithoutThumbnailIdentifier) as? BookListTableViewCell
            if cell == nil {
                cell = BookListTableViewCell(style: .default, reuseIdentifier: CellWithoutThumbnailIdentifier, needThumbnail: false)
            }
        }
        
        let payload = [
            "thumbnail": book.thumbnailImage,
            "title": book.name,
            "author": book.authors.first?.name ?? "",
            "publisher": book.publisher,
            "sentencesCount": book.sentences.count,
            "paragraphsCount": book.paragraphs.count,
            ] as [String : Any]
        cell?.payload = payload
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return modifyable
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let entity = results?[indexPath.row] else { return }
            
            let sheet = UIAlertController(title: "确定删除书籍？", message: entity.name, preferredStyle: .actionSheet)
            sheet.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
            sheet.addAction(title: "删除", style: .destructive, isEnabled: true) { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.coordinator.delete(a: entity, completion: nil)
            }
            navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
}

extension BookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let book = results?[indexPath.row] else { return }
        selectCompletion?(book)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}

private extension BookListViewController {
    @objc func actionCreate() {
        let createManully = UIAlertAction(title: "手动添加", style: .default) { [weak self] (_) in
            guard let strongSelf = self else { return }
            let nc = UINavigationController(rootViewController: CreateBookViewController(book: RealmBook()))
            strongSelf.navigationController?.present(nc, animated: true, completion: nil)
        }
        let createUsingScan = UIAlertAction(title: "识码添加", style: .default) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.showScanner()
        }
        
        let sheet = UIAlertController(title: "选择书籍添加方式", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(createUsingScan)
        sheet.addAction(createManully)
        sheet.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        navigationController?.present(sheet, animated: true, completion: nil)
    }
    
    func showScanner() {
        func _showScanner() {
            let vc = CodeScannerViewController(codeType: .bar)
            vc.completion = { [weak self] code, theVC in
                guard let strongSelf = self else { return }
                MainQueue.async {
                    debugPrint(code)
                    
                    theVC.dismiss(animated: true, completion: {
                        HUD.show(.labeledProgress(title: "查询中", subtitle: nil))
                        strongSelf.coordinator.queryBookFromRemote(isbn: code, completion: { (success, data, message) in
                            guard success else {
                                MainQueue.async {
                                    HUD.flash(.labeledError(title: message ?? "未知错误", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
                                }
                                return
                            }
                            MainQueue.async {
                                HUD.hide()
                                strongSelf.previewNewBook(data: data)
                            }
                        })
                    })
                }
            }
            navigationController?.present(vc, animated: true, completion: nil)
        }
        CodeScanner.canCaptureVideo(authorizedHandler: {
            MainQueue.async {
                _showScanner()
            }
        }) {
            Bartendar.handleTipAlert(message: "没有权限使用摄像头", on: nil)
        }
    }
    
    func previewNewBook(data: [String: Any]?) {
        let coordinator = RemoteBookCoordinator(with: data ?? [:])
        let vc = RemoteBookDetailViewController(with: coordinator)
        let nc = UINavigationController(rootViewController: vc)
        navigationController?.present(nc, animated: true, completion: nil)
    }
}
