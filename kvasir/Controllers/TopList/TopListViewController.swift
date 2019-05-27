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
private let ScaleFactor = 0.9 as CGFloat
private let ScaleDuration = 0.1

private let FocusedSection: [(title: String, url: String)] = [
    ("句摘", KvasirURL.allSentences.url()),
    ("段摘", KvasirURL.allParagraphs.url()),
]
private let Resources: [(title: String, url: String)] = [
    ("书籍", KvasirURL.allBooks.url()),
    ("\(RealmAuthor.toHuman())们", KvasirURL.allAuthors.url()),
    ("\(RealmTranslator.toHuman())们", KvasirURL.allTranslators.url()),
    ("\(RealmTag.toHuman())们", KvasirURL.allTags.url()),
]
private let ResourceCellIdentifier = "resource"

class TopListViewController: UIViewController {
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .grouped)
        view.backgroundColor = Color.init(hexString: ThemeConst.mainBackgroundColor)
        view.delegate = self
        view.dataSource = self
        view.register(TopListTableViewCell.self, forCellReuseIdentifier: TopListTableViewCell.reuseIdentifier())
        view.register(TopListTableViewHeaderActionable.self, forHeaderFooterViewReuseIdentifier: TopListTableViewHeaderActionable.reuseIdentifier())
        view.register(TopListTableViewHeaderPlain.self, forHeaderFooterViewReuseIdentifier: TopListTableViewHeaderPlain.reuseIdentifier())
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        return view
    }()
    
    private weak var sentencesCollectionView: UICollectionView? = nil
    private weak var paragraphCollectionView: UICollectionView? = nil
    
    private lazy var sentenceViewModelCoordinator: TopListCoordinator<RealmSentence> = { [unowned self ] in
        let coordinator = TopListCoordinator<RealmSentence>()
        coordinator.initialHandler = { _ in
            MainQueue.async {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                self.reloadSentenceView()
            }
        }
        coordinator.updateHandler = { (_, _, _) in
            MainQueue.async {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                self.reloadSentenceView()
            }
        }
        coordinator.errorHandler = { _ in
            MainQueue.async {
                Bartendar.handleSorryAlert(on: nil)
            }
        }
        return coordinator
    }()
    private lazy var paragraphViewModelCoordinator: TopListCoordinator<RealmParagraph> = { [unowned self ] in
        let coordinator = TopListCoordinator<RealmParagraph>()
        coordinator.initialHandler = { _ in
            MainQueue.async {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
                self.reloadParagraphView()
            }
        }
        coordinator.updateHandler = { (_, _, _) in
            MainQueue.async {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
                self.reloadParagraphView()
            }
        }
        coordinator.errorHandler = { _ in
            MainQueue.async {
                Bartendar.handleSorryAlert(on: nil)
            }
        }
        return coordinator
    }()
    private lazy var deputyCoodinator: TopListDeputyCoodinator = { [unowned self] in
        let coordinator = TopListDeputyCoodinator()
        coordinator.reload = { (bookCount, authorCount, translatorCount, tagCount) in
            self.tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .automatic)
        }
        return coordinator
    }()
    
    private var sentencesData: Results<RealmSentence>? {
        get {
            return sentenceViewModelCoordinator.results
        }
    }
    
    private var paragraphsData: Results<RealmParagraph>? {
        get {
            return paragraphViewModelCoordinator.results
        }
    }
    
    private var booksData: Results<RealmBook>? {
        get {
            return deputyCoodinator.bookResults
        }
    }
    
    private var authorsData: Results<RealmAuthor>? {
        get {
            return deputyCoodinator.authorResults
        }
    }
    
    private var translatorsData: Results<RealmTranslator>? {
        get {
            return deputyCoodinator.translatorResults
        }
    }
    
    private var tagData: Results<RealmTag>? {
        get {
            return deputyCoodinator.tagResults
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
        deputyCoodinator.reclaim()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        sentenceViewModelCoordinator.setupQuery(for: 0)
        paragraphViewModelCoordinator.setupQuery(for: 1)
        deputyCoodinator.setupQuery()
    }
    
    func reloadSentenceView() {
        MainQueue.async {
            self.sentencesCollectionView?.backgroundView = (self.sentencesData?.count ?? 0 <= 0) ? CollectionTypeEmptyBackgroundView(title: "右上角添加一个\(RealmSentence.toHuman())吧") : nil
            self.sentencesCollectionView?.reloadData()
        }
    }
    
    func reloadParagraphView() {
        MainQueue.async {
            self.paragraphCollectionView?.backgroundView = (self.paragraphsData?.count ?? 0 <= 0) ? CollectionTypeEmptyBackgroundView(title: "右上角添加一个\(RealmParagraph.toHuman())吧") : nil
            self.paragraphCollectionView?.reloadData()
        }
    }
}

private extension TopListViewController {
    func setupNavigationBar() {
        title = "最近"
        setupImmersiveAppearance()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = makeBarButtonItem(.plus, target: self, action: #selector(actionNew))
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    private func headerAccessoryTitleForSection(_ section: Int) -> String {
        switch section {
        case 0:
            return "查看全部 \(sentencesData?.count ?? 0)"
        case 1:
            return "查看全部 \(paragraphsData?.count ?? 0)"
        case 2:
            return "收集的资源"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < FocusedSection.count {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeaderActionable.reuseIdentifier()) as? TopListTableViewHeaderActionable else { return nil }
            header.title = FocusedSection[section].title
            header.actionTitle = headerAccessoryTitleForSection(section)
            header.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
            header.seeAllHandler = {
                MainQueue.async {
                    KvasirNavigator.push(FocusedSection[section].url)
                }
            }
            return header
        } else {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeaderPlain.reuseIdentifier()) as? TopListTableViewHeaderPlain else { return nil }
            header.title = headerAccessoryTitleForSection(section)
            header.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section >= FocusedSection.count else { return }
        
        let resource = Resources[indexPath.row]
        KvasirNavigator.push(resource.url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TopListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return FocusedSection.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < FocusedSection.count {
            return 1
        }
        return Resources.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < FocusedSection.count {
            return TopListTableViewCell.cellHeight
        }
        return 48
    }
    
    private func detailTextForResouceCellsAtIndexPath(_ indexPath: IndexPath) -> String {
        guard indexPath.section >= FocusedSection.count else {
            return ""
        }
        
        switch indexPath.row {
        case 0:
            return "\(booksData?.count ?? 0)"
        case 1:
            return "\(authorsData?.count ?? 0)"
        case 2:
            return "\(translatorsData?.count ?? 0)"
        case 3:
            return "\(tagData?.count ?? 0)"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < FocusedSection.count {
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
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: ResourceCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: ResourceCellIdentifier)
            }
            let resource = Resources[indexPath.row]
            cell?.textLabel?.text = resource.title
            cell?.detailTextLabel?.text = detailTextForResouceCellsAtIndexPath(indexPath)
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TopListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let location = getLocationOfCollectionView(collectionView) else { return 0 }
        
        switch location.section {
        case 0:
            return (sentencesData?.count ?? 0) <= ShowMost ? (sentencesData?.count ?? 0) : ShowMost
        case 1:
            return (paragraphsData?.count ?? 0) <= ShowMost ? (paragraphsData?.count ?? 0) : ShowMost
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: TopListCollectionViewCell
        
        let digest: RealmWordDigest? = {
            guard let location = getLocationOfCollectionView(collectionView) else { return nil }
            switch location.section {
            case 0:
                return sentencesData?[indexPath.row]
            case 1:
                return paragraphsData?[indexPath.row]
            default:
                return nil
            }
        }()
        if let hasImage = digest?.book?.hasImage, hasImage {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopListCollectionViewCellWithThumbnail.reuseIdentifier(), for: indexPath) as! TopListCollectionViewCell
            (cell as! TopListCollectionViewCellWithThumbnail).thumbnail = digest?.book?.thumbnailImage ?? ""
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopListCollectionViewCellWithoutThumbnail.reuseIdentifier(), for: indexPath) as! TopListCollectionViewCell
        }
        cell.title = digest?.title
        cell.bookName = digest?.book?.name
        cell.recordUpdatedDate = digest?.updateAtReadable
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TopListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionLocation = getLocationOfCollectionView(collectionView) else { return }
        
        switch collectionLocation.section {
        case 0:
            guard let digest = sentencesData?[indexPath.row] else { return }
            KvasirNavigator.push(KvasirURL.detailSentence.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        case 1:
            guard let digest = paragraphsData?[indexPath.row] else { return }
            KvasirNavigator.push(KvasirURL.detailParagraph.url(with: ["id": digest.id]), context: nil, from: navigationController, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopListCollectionViewCell else { return }
        cell.shrinkSize(scaleX: ScaleFactor, scaleY: ScaleFactor, duration: ScaleDuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopListCollectionViewCell else { return }
        cell.restoreSize(duration: ScaleDuration)
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
                KvasirURL.newSentence.url(),
                context: nil,
                wrap: UINavigationController.self,
                from: AppRootViewController,
                animated: true,
                completion: nil
            )
        }
        
        let actionParagraph = UIAlertAction(title: "段落", style: .default) { (_) in
            KvasirNavigator.present(
                KvasirURL.newParagraph.url(),
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
