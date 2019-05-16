//
//  PlainTextViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class PlainTextViewController: UIViewController {
    
    var navigationTitle: String? {
        get {
            return title
        }
        set {
            title = newValue
        }
    }
    
    var content: String? {
        get {
            return tvText.text
        }
        set {
            tvText.text = newValue
        }
    }
    
    private var presentedModally = false
    
    private lazy var tvText: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = UIFont.systemFont(ofSize: 20)
        view.textContainerInset = UIEdgeInsets(horizontal: 10, vertical: 20)
        return view
    }()
    
    private lazy var itemClose: UIBarButtonItem = UIBarButtonItem(customView: {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .times, fontSize: 22)
        btn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        return btn
    }())
    
    init(presentedModally modally: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.presentedModally = modally
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupImmersiveAppearance()
        setupBackItem()
        setupSubviews()
    }
    
    private func setupBackItem() {
        if presentedModally {
            navigationItem.leftBarButtonItem = itemClose
        }
    }
    
    private func setupSubviews() {
        view.backgroundColor = .white
        
        view.addSubview(tvText)
        tvText.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
