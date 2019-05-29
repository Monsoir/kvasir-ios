//
//  TagDetailViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import PKHUD

private let SectionInfos: [(title: String, url: String)] = [
    (title: "句摘", url: KvasirURL.allSentences.url()),
    (title: "段摘", url: KvasirURL.allParagraphs.url()),
    (title: "书籍", url: KvasirURL.allBooks.url()),
]

private let SectionMaxRows = 3

class TagDetailViewController: UnifiedViewController {
    
    private var coordinator: TagDetailCoordinator!
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .grouped)
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 200
        view.register(TopListTableViewHeaderActionable.self, forHeaderFooterViewReuseIdentifier: TopListTableViewHeaderActionable.reuseIdentifier())
        view.register(PlainTextViewFooter.self, forHeaderFooterViewReuseIdentifier: PlainTextViewFooter.reuseIdentifier())
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        return view
    }()
    private lazy var tableHeader: TagDetailHeader = TagDetailHeader()
    
    init(with configuration: [String : Any]) {
        self.coordinator = TagDetailCoordinator(with: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubviews()
        configureCoordinator()
        coordinator.query { [weak self] (success, _) in
            guard let self = self, success else { return }
            self.reloadView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.color = Color(hexString: coordinator.tagResult?.color ?? "")
        tableHeader.title = coordinator.tagResult?.name ?? ""
        tableHeader.frame = CGRect(x: 0, y: 0, width: tableView.width, height: TagDetailHeader.height)
        tableView.tableHeaderView = tableHeader
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureCoordinator() {
        coordinator.reloadHandler = { [weak self] _ in
            guard let self = self else { return }
            MainQueue.async {
                self.tableView.reloadData()
            }
        }
        coordinator.errorHandler = { [weak self] msg in
            guard let self = self else { return }
            MainQueue.async {
                self.navigationController?.popViewController()
                Bartendar.handleSorryAlert(message: msg, on: nil)
            }
        }
        coordinator.deleteHandler = { [weak self] in
            guard let self = self else { return }
            MainQueue.async {
                self.navigationController?.popViewController(animated: true)
                HUD.flash(.label("该标签已删除"), onView: nil, delay: 1.0, completion: nil)
            }
        }
    }
    
    private func reloadView() {
        tableView.reloadData()
        title = "\(RealmTag.toHuman)-\(coordinator.tagResult?.name ?? "")"
    }
}

extension TagDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionInfos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch section {
        case 0:
            count = coordinator.tagResult?.sentences.count ?? 0
        case 1:
            count = coordinator.tagResult?.paragraphs.count ?? 0
        case 2:
            count = coordinator.tagResult?.books.count ?? 0
        default:
            count = 0
        }
        return count > SectionMaxRows ? SectionMaxRows : count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1:
            return TextListTableViewCell.height
        case 2:
            return BookListTableViewCell.height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func cellForDigestAtIndexPath(_ indexPath: IndexPath, digest: RealmWordDigest?) -> UITableViewCell {
            guard let digest = digest else { return UITableViewCell() }
            
            var cell: TextListTableViewCell?
            if let hasImage = digest.book?.hasImage, hasImage {
                cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon)) as? TextListTableViewCell
                if cell == nil {
                    cell = TextListTableViewCell(
                        style: .default,
                        reuseIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithThumbnailIdentifierAddon),
                        needThumbnail: true
                    )
                }
                cell?.thumbnail = digest.book?.thumbnailImage ?? ""
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: TextListTableViewCell.reuseIdentifier(extra: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon)) as? TextListTableViewCell
                if cell == nil {
                    cell = TextListTableViewCell(
                        style: .default,
                        reuseIdentifier: TextListTableViewCell.cellWithoutThumbnailIdentifierAddon
                    )
                }
            }
            cell?.title = digest.title
            cell?.bookName = digest.book?.name
            cell?.recordUpdatedDate = digest.updateAtReadable
            return cell!
        }
        
        func cellForBookAtIndexPath(_ indexPath: IndexPath, book: RealmBook?) -> UITableViewCell {
            guard let book = book else { return UITableViewCell() }
            var cell: BookListTableViewCell?
            if book.hasImage {
                cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithThumbnailIdentifierAddon)) as? BookListTableViewCell
                if cell == nil {
                    cell = BookListTableViewCell(style: .default, reuseIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithThumbnailIdentifierAddon), needThumbnail: true)
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithoutThumbnailIdentifierAddon)) as? BookListTableViewCell
                if cell == nil {
                    cell = BookListTableViewCell(style: .default, reuseIdentifier: BookListTableViewCell.reuseIdentifier(extra: BookListTableViewCell.cellWithoutThumbnailIdentifierAddon), needThumbnail: false)
                }
            }
            
            let payload = [
                "thumbnail": book.thumbnailImage,
                "title": book.name,
                "author": book.authors.first?.name ?? "",
                "publisher": book.publisher,
                "sentencesCount": book.sentences.count,
                "paragraphsCount": book.paragraphs.count,
                ] as [String : Any]
            cell?.payload = payload
            return cell!
        }
        
        switch indexPath.section {
        case 0:
            let digest = coordinator.tagResult?.sentences[indexPath.row]
            return cellForDigestAtIndexPath(indexPath, digest: digest)
        case 1:
            let digest = coordinator.tagResult?.paragraphs[indexPath.row]
            return cellForDigestAtIndexPath(indexPath, digest: digest)
        case 2:
            let book = coordinator.tagResult?.books[indexPath.row]
            return cellForBookAtIndexPath(indexPath, book: book)
        default:
            return UITableViewCell()
        }
    }
}

extension TagDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TopListTableViewHeaderActionable.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopListTableViewHeaderActionable.reuseIdentifier()) as? TopListTableViewHeaderActionable else { return nil }
        
        func headerAccessoryTitleForSection(_ section: Int) -> String {
            let tag = coordinator.tagResult
            switch section {
            case 0:
                return "查看全部 \(tag?.sentences.count ?? 0)"
            case 1:
                return "查看全部 \(tag?.paragraphs.count ?? 0)"
            case 2:
                return "查看全部 \(tag?.books.count ?? 0)"
            default:
                return ""
            }
        }
        
        header.title = SectionInfos[section].title
        header.actionTitle = headerAccessoryTitleForSection(section)
        header.contentView.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        header.seeAllHandler = {
            MainQueue.async {
                KvasirNavigator.push(SectionInfos[section].url)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return coordinator.hasSentences ? 0 : PlainTextViewFooter.height
        case 1:
            return coordinator.hasParagraphs ? 0 : PlainTextViewFooter.height
        case 2:
            return coordinator.hasBooks ? 0 : PlainTextViewFooter.height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return coordinator.hasSentences ? nil : {
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTextViewFooter.reuseIdentifier()) as? PlainTextViewFooter
                footer?.title = "没有找到该\(RealmTag.toHuman)下的\(RealmSentence.toHuman)"
                return footer
            }()
        case 1:
            return coordinator.hasParagraphs ? nil : {
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTextViewFooter.reuseIdentifier()) as? PlainTextViewFooter
                footer?.title = "没有找到该\(RealmTag.toHuman)下的\(RealmParagraph.toHuman)"
                return footer
            }()
        case 2:
            return coordinator.hasBooks ? nil : {
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTextViewFooter.reuseIdentifier()) as? PlainTextViewFooter
                footer?.title = "没有找到该\(RealmTag.toHuman)下的\(RealmBook.toHuman)"
                return footer
            }()
        default:
            return nil
        }
    }
}
