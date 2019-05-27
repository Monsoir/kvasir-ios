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

private let CellWithThumbnailIdentifier = "with-thumbnail"
private let CellWithoutThumbnailIdentifier = "without-thumbnail"

class DigestListViewController<Digest: RealmWordDigest>: UnifiedViewController, UITableViewDataSource, UITableViewDelegate {

    private var coordinator: DigestListCoordinator<Digest>!
    private var results: Results<Digest>? {
        get {
            return coordinator.results
        }
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
    
    init(with payload: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        coordinator = DigestListCoordinator<Digest>(with: payload)
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
            RealmSentence.toMachine(): KvasirURL.newSentence.url(),
            RealmParagraph.toMachine(): KvasirURL.newParagraph.url(),
        ]
        KvasirNavigator.present(
            dict[Digest.toMachine()]!,
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
        let digest = results?[indexPath.row]
        
        if let _ = digest?.book?.hasImage {
            cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: CellWithThumbnailIdentifier)) as? TextListTableViewCell
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: TextListTableViewCell.reuseIdentifier(extra: CellWithThumbnailIdentifier),
                    needThumbnail: true
                )
            }
            cell?.thumbnail = digest?.book?.thumbnailImage ?? ""
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: CellWithoutThumbnailIdentifier)) as? TextListTableViewCell
            if cell == nil {
                cell = TextListTableViewCell(
                    style: .default,
                    reuseIdentifier: CellWithoutThumbnailIdentifier
                )
            }
        }
        
        cell?.title = digest?.title
        cell?.bookName = digest?.book?.name
        cell?.recordUpdatedDate = digest?.updateAtReadable
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let digest = results?[indexPath.row] else { return }
        switch digest {
        case is RealmSentence:
            KvasirNavigator.push(KvasirURL.detailSentence.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        case is RealmParagraph:
            KvasirNavigator.push(KvasirURL.detailParagraph.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        default:
            break
        }
    }
}

private extension DigestListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.rightBarButtonItem = makeBarButtonItem(.plus, target: self, action: #selector(actionCreate))
        title = coordinator.bookName.isEmpty ? Digest.toHuman() : "\(coordinator.bookName)的\(Digest.toHuman())"
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
        coordinator.initialLoadHandler = { [weak self] _ in
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
        coordinator.setupQuery()
    }
    
    func reloadBackgroundView() {
        self.tableView.backgroundView = self.results?.count ?? 0 <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有\(Digest.toHuman())的摘录", position: .upper) : nil
    }
    
    func reload() {
        MainQueue.async {
            self.reloadBackgroundView()
            self.title = self.coordinator.bookName.isEmpty ? Digest.toHuman() : "\(self.coordinator.bookName) - \(Digest.toHuman())"
            self.tableView.reloadData()
        }
    }
}
