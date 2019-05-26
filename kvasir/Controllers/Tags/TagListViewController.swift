//
//  TagListViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift

class TagListViewController: ResourceListViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagListCollectionViewCell.self, forCellWithReuseIdentifier: TagListCollectionViewCell.reuseIdentifier())
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    deinit {
        coordinator.reclaim()
        debugPrint("\(self) deinit")
    }
    
    private lazy var coordinator: TagListCoordinator = TagListCoordinator(with: self.configuration)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSubviews()
        configureCoordinator()
    }
    
    @objc private func actionCreate() {
    }
}

extension TagListViewController {
    private func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.rightBarButtonItem = makeBarButtonItem(.plus, target: self, action: #selector(actionCreate))
        title = configuration["title"] as? String ?? ""
    }
    
    private func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureCoordinator() {
        coordinator.initialLoadHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
        }
        coordinator.updateHandler = { [weak self] (deletions, insertions, modifications) in
            MainQueue.async {
                guard let self = self else { return }
                self.collectionView.deleteItems(at: deletions)
                self.collectionView.insertItems(at: insertions)
                self.collectionView.reloadItems(at: modifications)
                self.setupBackgroundIfNeeded()
            }
        }
        coordinator.errorHandler = { [weak self] _ in
            MainQueue.async {
                guard let self = self else { return }
                Bartendar.handleSorryAlert(on: self.navigationController)
            }
        }
        coordinator.setupQuery()
    }
    
    private func setupBackgroundIfNeeded() {
        guard let count = coordinator.results?.count, count <= 0 else {
            collectionView.backgroundView = nil
            return
        }
        collectionView.backgroundView = CollectionTypeEmptyBackgroundView(title: "右上角添加一个标签吧", position: .upper)
    }
}

extension TagListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coordinator.results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagListCollectionViewCell.reuseIdentifier(), for: indexPath) as! TagListCollectionViewCell
        
        guard let entity = coordinator.results?[indexPath.row] else { return cell }
        cell.title = entity.name
        cell.color = Color(hexString: entity.color)
        cell.contentViewBackgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return cell
    }
}

extension TagListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TagListCollectionViewCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
