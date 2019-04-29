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

typealias BookSelectCompletion = (_ book: RealmBook) -> Void

class BookListViewController: UIViewController {
    private lazy var bookResults: Results<RealmBook>? = RealmBook.allObjectsSortedByUpdatedAt(of: RealmBook.self)
    private var realmNotificationToken: NotificationToken?
    var selectCompletion: BookSelectCompletion?
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(BookListTableViewCell.height)
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(selectCompletion: @escaping BookSelectCompletion) {
        self.init(nibName: nil, bundle: nil)
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
        setupRealmNotification()
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
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

extension BookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let book = bookResults?[indexPath.row] else { return }
        selectCompletion?(book)
    }
}

private extension BookListViewController {
    @objc func actionCreate() {
        let nc = UINavigationController(rootViewController: CreateBookViewController(book: RealmBook()))
        navigationController?.present(nc, animated: true, completion: nil)
    }
}
