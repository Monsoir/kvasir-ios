//
//  TopListViewController.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import RealmSwift

private let ShowMost = 5

class TopListViewController: UIViewController {
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(TopListConstants.cellHeight)
        view.delegate = self
        view.dataSource = self
        view.register(TopListTableViewCell.self, forCellReuseIdentifier: TopListTableViewCell.reuseIdentifier())
        view.register(TopListTableViewHeader.self, forHeaderFooterViewReuseIdentifier: TopListTableViewHeader.reuseIdentifier())
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        return view
    }()
    
    private weak var sentencesCollectionView: UICollectionView? = nil
    private weak var paragraphCollectionView: UICollectionView? = nil
    
    private lazy var sentenceViewModelCoordinator: TopListCoordinator = { [weak self ] in
        let coordinator = TopListCoordinator(mode: .local, digestType: .sentence)
        coordinator.reload = { data in
            self?.sentencesData = data
            self?.reloadSentenceView()
        }
        return coordinator
    }()
    private lazy var paragraphViewModelCoordinator: TopListCoordinator = { [weak self ] in
        let coordinator = TopListCoordinator(mode: .local, digestType: .paragraph)
        coordinator.reload = { data in
            self?.paragraphsData = data
            self?.reloadParagraphView()
        }
        return coordinator
    }()
    
    private var sentencesData: [TopListViewModel] = [] {
        didSet {
            sentencesCollectionView?.reloadData()
        }
    }
    
    private var paragraphsData: [TopListViewModel] = [] {
        didSet {
            paragraphCollectionView?.reloadData()
        }
    }
    
    private lazy var cellViewModelCarriers: [TopListCellCarrier] = { [unowned self] in
        return [
            TopListCellCarrier(
                label: "sentence",
                collectionViewDelegate: self,
                collectionViewDataSource: self,
                lastOffsetX: 0
            ),
            TopListCellCarrier(
                label: "paragraph",
                collectionViewDelegate: self,
                collectionViewDataSource: self,
                lastOffsetX: 0
            ),
        ]
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        
        sentenceViewModelCoordinator.reclaim()
        paragraphViewModelCoordinator.reclaim()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        sentenceViewModelCoordinator.fetchData()
        paragraphViewModelCoordinator.fetchData()
    }
    
    func reloadSentenceView() {
        sentencesCollectionView?.backgroundView = sentencesData.count <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有摘录的句子") : nil
        sentencesCollectionView?.reloadData()
    }
    
    func reloadParagraphView() {
        paragraphCollectionView?.backgroundView = paragraphsData.count <= 0 ? CollectionTypeEmptyBackgroundView(title: "还没有摘录的段落") : nil
        paragraphCollectionView?.reloadData()
    }
}

private extension TopListViewController {
    func setupNavigationBar() {
        title = "最近"
        setupImmersiveAppearance()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let newItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionNew))
        navigationItem.rightBarButtonItem = newItem
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

// MARK: - UITableViewDelegate
extension TopListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeader.reuseIdentifier()) as? TopListTableViewHeader else { return nil }
        
        var digestType: DigestType = .sentence
        switch section {
        case 0:
            header.title = "句摘"
            digestType = .sentence
        case 1:
            header.title = "段摘"
            digestType = .paragraph
        default:
            break;
        }
        
        header.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        header.seeAllHandler = {
            let dict = [
                DigestType.sentence: KvasirURLs.allSentences,
                DigestType.paragraph: KvasirURLs.allParagraphs,
            ]
            DispatchQueue.main.async {
                KvasirNavigator.push(dict[digestType]!)
            }
        }
        
        return header
    }
}

// MARK: - UITableViewDataSource
extension TopListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellViewModelCarriers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopListTableViewCell.reuseIdentifier(), for: indexPath) as! TopListTableViewCell
        cell.carrier = cellViewModelCarriers[indexPath.section]
        switch indexPath.section {
        case 0:
            sentencesCollectionView = cell.collectionView
        case 1:
            paragraphCollectionView = cell.collectionView
        default:
            break
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSource
extension TopListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let location = getLocationOfCollectionView(collectionView) else { return 0 }
        
        switch location.section {
        case 0:
            return sentencesData.count
        case 1:
            return paragraphsData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopListCollectionViewCell.reuseIdentifier(), for: indexPath) as! TopListCollectionViewCell
        
        let digest: TopListViewModel? = {
            guard let location = getLocationOfCollectionView(collectionView) else { return nil }
            switch location.section {
            case 0:
                return sentencesData[indexPath.row]
            case 1:
                return paragraphsData[indexPath.row]
            default:
                return nil
            }
        }()
        cell.title = digest?.title
        cell.bookName = digest?.bookName
        cell.recordUpdatedDate = digest?.updatedAt
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TopListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionLocation = getLocationOfCollectionView(collectionView) else { return }
        
        switch collectionLocation.section {
        case 0:
            guard let digests = RealmSentence.allObjectsSortedByUpdatedAt() else { return }
            let digest = digests[indexPath.row]
            KvasirNavigator.push(KvasirURLs.detailSentence(digest.id), context: nil, from: navigationController, animated: true)
        case 1:
            guard let digests = RealmParagraph.allObjectsSortedByUpdatedAt() else { return }
            let digest = digests[indexPath.row]
            KvasirNavigator.push(KvasirURLs.detailParagraph(digest.id), context: nil, from: navigationController, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopListCollectionViewCell else { return }
        cell.shrinkSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopListCollectionViewCell else { return }
        cell.restoreSize()
    }
}


// MARK: - View Helpers
private extension TopListViewController {
    func getLocationOfCollectionView(_ collectionView: UICollectionView) -> IndexPath? {
        guard let theTableViewCell = collectionView.superview?.superview as? TopListTableViewCell else { return nil }
        guard let theTableView = theTableViewCell.superview as? UITableView else { return nil }
        
        // 刚创建 view 的时候，cell 不可见，下面的方法会返回 nil
//        return theTableView.indexPath(for: theTableViewCell)
        
        // 使用下面这个方法是应对刚创建 view 时候的 workaround
        return theTableView.indexPathForRow(at: theTableViewCell.center)
    }
}

private extension TopListViewController {
    @objc func actionNew() {
        let sheet = UIAlertController(title: "创建摘录", message: "请选择摘录类型", preferredStyle: .actionSheet)
        let actionSentence = UIAlertAction(title: "句子", style: .default) { (_) in
            KvasirNavigator.present(
                KvasirURLs.newSentence,
                context: nil,
                wrap: UINavigationController.self,
                from: AppRootViewController,
                animated: true,
                completion: nil
            )
        }
        
        let actionParagraph = UIAlertAction(title: "段落", style: .default) { (_) in
            KvasirNavigator.present(
                KvasirURLs.newParagraph,
                context: nil,
                wrap: UINavigationController.self,
                from: AppRootViewController,
                animated: true,
                completion: nil
            )
        }
        
        let actionCancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        sheet.addAction(actionSentence)
        sheet.addAction(actionParagraph)
        sheet.addAction(actionCancel)
        
        present(sheet, animated: true, completion: nil)
    }
}
