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

class CreatorListViewController<Creator: RealmCreator>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    typealias SelectCompletion =  ((_ creators: [Creator]) -> Void)
    private lazy var creatorResults: Results<Creator>? = Creator.allObjectsSortedByUpdatedAt(of: Creator.self)
    private var realmNotificationToken: NotificationToken?
    private var selectCompletion: SelectCompletion?
    private var preSelectionIds: [String] = []
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(BookListTableViewCell.height)
        view.dataSource = self
        view.delegate = self
        view.register(BookListTableViewCell.self, forCellReuseIdentifier: BookListTableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
        return view
    }()
    
    init(selectCompletion completion: SelectCompletion? = nil, preSelections: [Creator]) {
        self.selectCompletion = completion
        self.preSelectionIds = preSelections.map({ (creator) -> String in
            return creator.id
        })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        setupRealmNotification()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creatorResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier(), for: indexPath) as! BookListTableViewCell
        
        guard let creator = creatorResults?[indexPath.row] else { return UITableViewCell() }
        cell.textLabel?.text = "\(creator.name) / \(creator.localeName)"
        cell.accessoryType = preSelectionIds.contains(creator.id) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let creator = creatorResults?[indexPath.row] else { return }
        if let completion = selectCompletion, !preSelectionIds.contains(creator.id) {
            completion([creator])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController()
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
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))
        title = "我收集的\(Creator.toHuman())"
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupRealmNotification() {
        realmNotificationToken = creatorResults?.observe({ [weak self] (changes) in
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

typealias AuthorListViewController = CreatorListViewController<RealmAuthor>
typealias TranslatorListViewController = CreatorListViewController<RealmTranslator>
