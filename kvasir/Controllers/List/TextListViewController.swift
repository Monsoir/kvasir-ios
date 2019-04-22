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

class TextListViewController: UIViewController {

    private lazy var sentenceResults: Results<RealmSentence>? = RealmSentence.allObjectsSortedByUpdatedAt()
    private lazy var paragraphResults: Results<RealmParagraph>? = RealmParagraph.allObjectsSortedByUpdatedAt()
    private var realmNotificationToken: NotificationToken?
    private var digestType = DigestType.sentence
    
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
    
    init(type: DigestType) {
        self.digestType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        switch digestType {
        case .sentence:
            realmNotificationToken = sentenceResults?.observe({ [weak self] changes in
                switch changes {
                case .initial: fallthrough
                case .update:
                    self?.tableView.reloadData()
                case .error:
                    break
                }
            })
        case .paragraph:
            realmNotificationToken = sentenceResults?.observe({ [weak self] changes in
                switch changes {
                case .initial: fallthrough
                case .update:
                    self?.tableView.reloadData()
                case .error:
                    break
                }
            })
        }
    }
}

private extension TextListViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        switch digestType {
        case .sentence:
            title = "句子"
        case .paragraph:
            title = "段落"
        }
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
}

extension TextListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch digestType {
        case .sentence:
            return sentenceResults?.count ?? 0
        case .paragraph:
            return paragraphResults?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(), for: indexPath) as! TextListTableViewCell
        
        let digest: RealmWordDigest? = {
            switch digestType {
            case .sentence:
                return sentenceResults?[indexPath.row]
            case .paragraph:
                return paragraphResults?[indexPath.row]
            }
        }()
        
        let outline = digest?.displayOutline()
        cell.title = outline?.title
        cell.bookName = outline?.bookName
        cell.recordUpdatedDate = outline?.updatedAt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextNC: UIViewController? = {
            switch digestType {
            case .sentence:
                guard let digest = sentenceResults?[indexPath.row] else { return nil }
                return TextDetailViewController(mode: .local, digestType: .sentence, digestId: digest.id)
            case .paragraph:
                guard let digest = paragraphResults?[indexPath.row] else { return nil }
                return TextDetailViewController(mode: .local, digestType: .paragraph, digestId: digest.id)
            }
        }()
        guard let nc = nextNC else { return }
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(nc)
        }
    }
}

extension TextListViewController: UITableViewDelegate {}

