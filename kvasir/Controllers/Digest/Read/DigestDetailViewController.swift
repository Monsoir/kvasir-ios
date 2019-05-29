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

private let ContainerHeight = 50

class DigestDetailViewController<Digest: RealmWordDigest>: UnifiedViewController {
    
    private var coordinator: DigestDetailCoordinator<Digest>!
    private var entity: Digest? {
        get {
            return coordinator.entity
        }
    }
    
    private lazy var scrollableContainer: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    private lazy var headerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var lbContent: SelectableLabel = { [unowned self] in
        let view = SelectableLabel()
        view.numberOfLines = 0
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(self.toCopyContentGesture)
        return view
    }()
    
    private lazy var toCopyContentGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPressGesture(recognizer:)))
    
    private lazy var btnContentEdit: UIButton = {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .paintBrush)
        btn.addTarget(self, action: #selector(actionEditContent), for: .touchUpInside)
        btn.isHidden = true
        return btn
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
        NSAttributedString.Key.font: UIFont(name: "PingFangSC-Light", size: 24)!,
        NSAttributedString.Key.paragraphStyle: {
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.justified
            paragraphStyle.paragraphSpacing = 6.0
            paragraphStyle.paragraphSpacingBefore = 6.0
            return paragraphStyle
        }(),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        configureCoordinator()
        coordinator.queryOne { [weak self] (success, entity) in
            guard success else {
                Bartendar.handleSimpleAlert(title: "提示", message: "没有找到数据", on: self?.navigationController)
                return
            }
            self?.reloadData()
        }
    }
    
    init(digestId: String) {
        self.coordinator = DigestDetailCoordinator(digestId: digestId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
        
        coordinator.reclaim()
    }
    
    @objc func actionDel() {
        deleteDigest()
    }
    
    @objc private func actionEditContent() {
        showContentEdit()
    }
    
    @objc private func actionLongPressGesture(recognizer: UIGestureRecognizer) {
        if recognizer == toCopyContentGesture {
            guard let theView = recognizer.view else { return }
            showMenuItems(on: theView)
        }
    }
    
    @objc private func actionFormore() {
        let vc = DigestMoreDetailViewController<Digest>(digestId: coordinator.digestId)
        navigationController?.pushViewController(vc)
    }
}

private extension DigestDetailViewController {
    func setupNavigationBar() {
        title = "\(Digest.toHuman) - 正文"
        setupImmersiveAppearance()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = makeBarButtonItem(.ellipsisH, target: self, action: #selector(actionFormore))
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        buttonsContainer.addSubview(btnEdit)
        buttonsContainer.addSubview(btnDel)
        btnEdit.addTarget(self, action: #selector(actionEditContent), for: .touchUpInside)
        
        view.addSubview(scrollableContainer)
        view.addSubview(buttonsContainer)
        scrollableContainer.addSubview(container)
        container.addSubview(headerContentView)
        headerContentView.addSubview(lbContent)
        
        scrollableContainer.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsContainer.snp.top)
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        headerContentView.snp.makeConstraints { (make) in
            make.top.leading.equalTo(10)
            make.bottom.trailing.equalTo(-10)
        }
        
        lbContent.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.trailing.equalToSuperview().offset(-10)
        }
        
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
    }
    
    func configureCoordinator() {
        coordinator.reload = { [weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
        }
        coordinator.errorHandler = { [weak self] msg in
            guard let strongSelf = self else { return }
            MainQueue.async {
                strongSelf.navigationController?.popToRootViewController(animated: true)
                Bartendar.handleSorryAlert(message: msg, on: nil)
            }
        }
        coordinator.entityDeleteHandler = { [weak self] in
            guard let strongSelf = self else { return }
            MainQueue.async {
                strongSelf.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

private extension DigestDetailViewController {
    func deleteDigest() {
        let alert = UIAlertController.init(title: "确定删除此条摘录吗？", message: nil, preferredStyle: .alert)
        alert.addAction(title: "确定", style: .destructive, isEnabled: true) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.coordinator?.delete(completion: { (success) in
                DispatchQueue.main.async {
                    if !success {
                        Bartendar.handleSorryAlert(message: "删除失败", on: self?.navigationController)
                        return
                    }
                }
            })
        }
        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func showContentEdit() {
        guard let editingData = entity else { return }
        let vc = DigestEditViewController(text: editingData.content, singleLine: Digest.self === RealmSentence.self) { [weak self] (text) in
            do {
                let putInfo = ["content": text]
                try self?.coordinator.put(info: putInfo)
            } catch let e as ValidateError {
                Bartendar.handleTipAlert(message: e.message, on: self?.navigationController)
                return
            } catch {
                Bartendar.handleSorryAlert(on: self?.navigationController)
                return
            }
            
            self?.coordinator.update(completion: { (success) in
                guard success else {
                    Bartendar.handleSorryAlert(message: "更新失败", on: self?.navigationController)
                    return
                }
                
                MainQueue.async {
                    self?.navigationController?.popViewController()
                    self?.reloadData()
                }
            })
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMenuItems(on theView: UIView) {
        guard let superView = theView.superview else { return }
        let menuController = UIMenuController.shared
        guard !menuController.isMenuVisible else { return }
        menuController.setTargetRect(theView.frame, in: superView)
        menuController.setMenuVisible(true, animated: true)
        theView.becomeFirstResponder()
    }
}

private extension DigestDetailViewController {
    func reloadData() {
        MainQueue.async {
            self.lbContent.attributedText = NSAttributedString(string: self.entity?.content ?? "", attributes: self.contentAttributes)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
}
