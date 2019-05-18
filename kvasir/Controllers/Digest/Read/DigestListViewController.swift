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

class DigestListViewController<Digest: RealmWordDigest>: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
        view.register(TextListTableViewCell.self, forCellReuseIdentifier: TextListTableViewCell.reuseIdentifier())
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
            RealmSentence.toMachine(): KvasirURLs.newSentence,
            RealmParagraph.toMachine(): KvasirURLs.newParagraph,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(), for: indexPath) as! TextListTableViewCell
        
        let digest = results?[indexPath.row]
        
        cell.title = digest?.title
        cell.bookName = digest?.book?.name
        cell.recordUpdatedDate = digest?.updateAtReadable
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let digest = results?[indexPath.row] else { return }
        switch digest {
        case is RealmSentence:
            KvasirNavigator.push(KvasirURLs.detailSentence(digest.id), context: nil, from: navigationController, animated: true)
        case is RealmParagraph:
            KvasirNavigator.push(KvasirURLs.detailParagraph(digest.id), context: nil, from: navigationController, animated: true)
        default:
            break
        }
    }
}

private extension DigestListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))
        title = coordinator.bookName.isEmpty ? Digest.toHuman() : "\(coordinator.bookName)的\(Digest.toHuman())"
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureCoordinator() {
        coordinator.reload = { [weak self] _ in
            self?.reload()
        }
        coordinator.errorHandler = nil
        coordinator.setupQuery()
    }
    
    func reload() {
        MainQueue.async {
            self.tableView.backgroundView = self.results?.count ?? 0 <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有\(Digest.toHuman())的摘录", position: .upper) : nil
            self.title = self.coordinator.bookName.isEmpty ? Digest.toHuman() : "\(self.coordinator.bookName) - \(Digest.toHuman())"
            self.tableView.reloadData()
        }
    }
}
