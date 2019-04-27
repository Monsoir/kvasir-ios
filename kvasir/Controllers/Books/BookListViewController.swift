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

class BookListViewController: UIViewController {
    private lazy var bookResults: Results<RealmBook>? = RealmBook.allObjectsSortedByUpdatedAt(of: RealmBook.self)
    private var realmNotificationToken: NotificationToken?
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(BookListTableViewCell.height)
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        setupRealmNotification()
    }
}

private extension BookListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))
        title = "选择书籍"
    }

    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupRealmNotification() {
        realmNotificationToken = bookResults?.observe({ [weak self] (changes) in
            switch changes {
            case .initial: fallthrough
            case .update:
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .error:
                break
            }
        })
    }
}

extension BookListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier(), for: indexPath)
        
        guard let book = bookResults?[indexPath.row] else { return cell }
        cell.textLabel?.text = book.name
        return cell
    }
}

extension BookListViewController: UITableViewDelegate {}

private extension BookListViewController {
    @objc func actionCreate() {
        let nc = UINavigationController(rootViewController: CreateBookViewController(book: RealmBook()))
        navigationController?.present(nc, animated: true, completion: nil)
    }
}
