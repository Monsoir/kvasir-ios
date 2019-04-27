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

class TextListViewController<Digest: RealmWordDigest>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private lazy var results: Results<Digest>? = Digest.allObjectsSortedByUpdatedAt(of: Digest.self)
    private var realmNotificationToken: NotificationToken?
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(TopListConstants.cellHeight)
        view.delegate = self
        view.dataSource = self
        view.register(TextListTableViewCell.self, forCellReuseIdentifier: TextListTableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        return view
    }()
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        
        realmNotificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        realmNotificationToken = results?.observe({ [weak self] changes in
            switch changes {
            case .initial: fallthrough
            case .update:
                self?.reload()
            case .error:
                break
            }
        })
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
        
        let outline = digest?.displayOutline()
        cell.title = outline?.title
        cell.bookName = outline?.bookName
        cell.recordUpdatedDate = outline?.updatedAt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let digest = results?[indexPath.row] else { return }
        let nextNC = TextDetailViewController(digestId: digest.id)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(nextNC)
        }
    }
}

private extension TextListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))
        title = Digest.toHuman()
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
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.backgroundView = self.results?.count ?? 0 <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有\(Digest.toHuman())的摘录", position: .upper) : nil
            self.tableView.reloadData()
        }
    }
}
