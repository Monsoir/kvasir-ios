//
//  TextDetailViewController.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift

private let SectionTitles = [
    "书名",
    "作者",
    "译者",
    "出版社",
    "摘录页码",
    "上次修改时间",
]

private let ContainerHeight = 50

class TextDetailViewController<Digest: RealmWordDigest>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    private lazy var headerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var lbContent: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var infoTableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
//        view.rowHeight = 80
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.register(DetailInfoTableViewCell.self, forCellReuseIdentifier: DetailInfoTableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
//        view.separatorStyle = .none
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        return view
    }()
    
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        return view
    }()
    
    private lazy var btnEdit: UIButton = makeAFunctionalButtonWith(title: "修改")
    private lazy var btnDel: UIButton = { [unowned self] in
        let btn = makeAFunctionalButtonWith(title: "删除")
        btn.setTitleColor(.red, for: .normal)
        btn.addTarget(self, action: #selector(actionDel), for: .touchUpInside)
        return btn
    }()
    
    private lazy var contentAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 28)!
    ]
    
    private var coordinator: TextDetailCoordinator<Digest>?
    private var data: TextDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        self.coordinator?.reload = { [weak self] data in
            self?.data = data
            self?.reloadData()
        }
        self.coordinator?.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight = lbContent.attributedText?.height(containerWidth: infoTableView.bounds.width) ?? 0
        headerView.height = headerHeight + 100
        
        infoTableView.tableHeaderView = headerView
    }
    
    init(digestId: String) {
        self.coordinator = TextDetailCoordinator(digestId: digestId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        
        coordinator?.reclaim()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoTableViewCell.reuseIdentifier(), for: indexPath) as! DetailInfoTableViewCell
        
        guard let digest = data else { return UITableViewCell() }
        cell.label = SectionTitles[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.value = digest.bookName
        case 1:
            cell.value = digest.authors
        case 2:
            cell.value = digest.translators
        case 3:
            cell.value = digest.publisher
        case 4:
            cell.value = "\(digest.pageIndex)"
        case 5:
            cell.value = digest.updatedAt
        default:
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func actionEdit() {
        guard let coordinator = coordinator, let model = coordinator.model else { return }
        
        let editingDigest = model.detached()
        let nextVC = TextEditViewController<Digest>(digest: editingDigest, creating: false)
        let nextNC = UINavigationController(rootViewController: nextVC)
        UIApplication.shared.keyWindow?.rootViewController?.present(nextNC, animated: true, completion: nil)
    }
    
    @objc func actionDel() {
        guard let coordinator = coordinator, let _ = coordinator.model else { return }
        
        let alert = UIAlertController.init(title: "确定删除此条摘录吗？", message: nil, preferredStyle: .alert)
        alert.addAction(title: "确定", style: .destructive, isEnabled: true) { [weak self] (_) in
            guard let strongSelf = self else { return }
            if coordinator.delete() {
                strongSelf.navigationController?.popViewController()
            } else {
                #warning("删除出错处理")
            }
        }
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

private extension TextDetailViewController {
    func setupNavigationBar() {
        title = "\(Digest.toHuman()) - 正文"
        setupImmersiveAppearance()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        headerView.addSubview(headerContentView)
        headerContentView.addSubview(lbContent)
        headerContentView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.trailing.equalToSuperview().offset(-10)
            make.center.equalToSuperview()
        }
        lbContent.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.center.equalToSuperview()
        }
        
        view.addSubview(infoTableView)
        view.addSubview(buttonsContainer)
        
        buttonsContainer.addSubview(btnEdit)
        buttonsContainer.addSubview(btnDel)
        btnEdit.addTarget(self, action: #selector(actionEdit), for: .touchUpInside)
        
        buttonsContainer.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(ContainerHeight)
            make.trailing.equalTo(buttonsContainer.snp.trailing)
        }
        
        btnEdit.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        btnDel.snp.makeConstraints { (make) in
            make.right.equalTo(btnEdit.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        infoTableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(buttonsContainer.snp.top)
        }
    }
}

private extension TextDetailViewController {
    func reloadData() {
        lbContent.attributedText = NSAttributedString(string: data?.content ?? "", attributes: contentAttributes)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        infoTableView.reloadData()
    }
}
