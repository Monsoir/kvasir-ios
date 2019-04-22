//
//  TopListTableViewCell.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

private let CellSpacings = 10 as CGFloat
private let CellWidth = 300 as CGFloat

class TopListTableViewCell: UITableViewCell {
    var carrier: TopListCellCarrier? = nil {
        didSet {
            guard let c = carrier else {
                return
            }
            
            collectionView.delegate = c.collectionViewDelegate
            collectionView.dataSource = c.collectionViewDataSource
            collectionView.reloadData()
            collectionView.setContentOffset(CGPoint(x: c.lastOffsetX, y: 0), animated: false)
        }
    }
    
    private(set) internal var collectionView: UICollectionView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        super.updateConstraints()
    }
}

private extension TopListTableViewCell {
    func setupSubviews() {
        selectionStyle = .none
        
        let collectionViewLayout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout();
            layout.itemSize = CGSize(width: ScreenWidth - 100, height: TopListConstants.cellHeight - CellSpacings)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = CellSpacings
            layout.sectionInset = UIEdgeInsets(top: 0, left: TopListConstants.collectionViewMargin, bottom: 0, right: TopListConstants.collectionViewMargin)
            return layout
        }()
        collectionView = {
            let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
            view.register(TopListCollectionViewCell.self, forCellWithReuseIdentifier: TopListCollectionViewCell.reuseIdentifier())
            view.backgroundColor = .white
            view.bounces = true
            return view
        }()
        contentView.addSubview(collectionView)
    }
}
