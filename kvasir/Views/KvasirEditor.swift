//
//  KvasirEditor.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import SnapKit

class KvasirEditor: UIView {
    
    var text: String {
        set {
            editor.text = text
        }
        get {
            return editor.text
        }
    }
    
    var backend: UITextView {
        get {
            return editor
        }
    }
    
    private var noCarriageReturn = false
    private lazy var editor: UITextView = { [unowned self] in
        let view = UITextView()
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.font = PingFangSCRegularFont?.withSize(25)
        view.bounces = true
        view.tintColor = Color(hexString: ThemeConst.outlineColor)
        view.textContainerInset = UIEdgeInsets(horizontal: 20, vertical: 20)
        if self.noCarriageReturn {
            view.delegate = self
            view.returnKeyType = .done
        }
        return view
    }()
    
    init(noCarriageReturn: Bool = false) {
        super.init(frame: .zero)
        self.noCarriageReturn = noCarriageReturn
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
        editor.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        addSubview(editor)
    }
}

extension KvasirEditor: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView == editor else { return true }
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
