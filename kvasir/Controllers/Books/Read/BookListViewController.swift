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

class BookListViewController: ResourceListViewController {
    
    private lazy var coordinator: BookListCoordinator = BookListCoordinator(configuration: self.configuration)
    private var results: Results<RealmBook>? {
        get {
            return coordinator.results
        }
    }
    private var selectCompletion: ((_: RealmBook, _: UIViewController) -> Void)? {
        return configuration["completion"] as? (_: RealmBook, _: UIViewController) -> Void
    }
    private var noBooksPlaceholder: String {
        return configuration["placeholder"] as? String ?? "没有搜索到收藏的书籍"
    }
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = BookListTableViewCell.height
        view.estimatedRowHeight = 200
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.tableFooterView = UIView()
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(configuration: [String : Any]) {
        super.init(configuration: configuration)
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
        if canAdd {
            navigationItem.rightBarButtonItem = makeBarButtonItem(.plus, target: self, action: #selector(actionCreate))
        }
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
        coordinator.initialHandler = { [weak self] _ in
            MainQueue.async {
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
                strongSelf.setupBackgroundIfNeeded()
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifications) in
            MainQueue.async {
                guard let strongSelf = self else { return }
                strongSelf.tableView.msr.updateRows(deletions: deletions, insertions: insertions, modifications: modifications, with: .fade)
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
        tableView.backgroundView = CollectionTypeEmptyBackgroundView(title: self.noBooksPlaceholder, position: .upper)
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
            cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithThumbnailIdentifierAddon)) as? BookListTableViewCell
            if cell == nil {
                cell = BookListTableViewCell(style: .default, reuseIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithThumbnailIdentifierAddon), needThumbnail: true)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithoutThumbnailIdentifierAddon)) as? BookListTableViewCell
            if cell == nil {
                cell = BookListTableViewCell(style: .default, reuseIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithoutThumbnailIdentifierAddon), needThumbnail: false)
            }
        }
        
        let payload = [
            "thumbnail": book.thumbnailImage,
            "title": book.name,
            "author": book.authors.first?.name ?? "",
            "publisher": book.publisher,
            "sentencesCount": book.digests.filter("\(#keyPath(RealmWordDigest.category)) == %@", RealmWordDigest.Category.sentence.rawValue).count,
            "paragraphsCount": book.digests.filter("\(#keyPath(RealmWordDigest.category)) == %@", RealmWordDigest.Category.paragraph.rawValue).count,
            ] as [String : Any]
        cell?.payload = payload
        return cell!
    }
}

extension BookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectCompletion = selectCompletion {
            guard let book = results?[indexPath.row] else { return }
            selectCompletion(book, self)
        } else {
            guard let book = results?[indexPath.row] else { return }
            KvasirNavigator.push(KvasirURL.detailBook.url(with: ["id": book.id]))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension BookListViewController {
    @objc func actionCreate() {
        let createManully = UIAlertAction(title: "手动添加", style: .default) { (_) in
            let config: Configuration = [
                "completion": { (vc: UIViewController) in
                    vc.dismiss(animated: true, completion: nil)
                },
            ]
            KvasirNavigator.present(KvasirURL.newBookManully.url(), context: config, wrap: UINavigationController.self)
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
            vc.delegate = self
            navigationController?.present(vc, animated: true, completion: nil)
        }
        CodeScanner.canCaptureVideo(authorizedHandler: {
            MainQueue.async {
                _showScanner()
            }
        }) {
            Bartendar.handleTipAlert(message: "没有足够权限使用摄像头", on: nil)
        }
    }
    
    func previewNewBook(code: String) {
        let config: Configurable.Configuration = [
            "code": code,
            "completion": { (vc: UIViewController) in
                vc.dismiss(animated: true, completion: nil)
            },
        ]
        KvasirNavigator.present(KvasirURL.newBookScanly.url(), context: config, wrap: UINavigationController.self)
    }
}

extension BookListViewController: CodeScannerViewControllerDelegate {
    func codeScannerViewController(_ vc: CodeScannerViewController, didScanCode code: String) {
        vc.stopScanning()
        MainQueue.async {
            if code.msr.isISBN {
                vc.dismiss(animated: true, completion: {
                    self.previewNewBook(code: code)
                })
            } else {
                Bartendar.handleTipAlert(message: "不符合规范的 ISBN", on: nil, afterConfirm: { [weak vc] in
                    guard let vc = vc else { return }
                    vc.startScanning()
                })
            }
        }
    }
}
