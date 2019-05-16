//
//  EurekaFillOrSelectRow.swift
//  kvasir
//
//  Created by Monsoir on 5/14/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Eureka

class EurekaFillableAndActionableCell: _FieldCell<String>, CellType {
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var action: ((_ value: String?) -> Void)?
    
    private lazy var btnAction: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        btn.setBackgroundImage(UIImage(named: "inline-search"), for: .normal)
        btn.addTarget(self, action: #selector(actionToggle), for: .touchUpInside)
        return btn
    }()
    
    @objc private func actionToggle() {
        action?(row.value)
    }
    
    override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default
        
        
        textField.clearButtonMode = .whileEditing
        textField.rightView = btnAction
        textField.rightViewMode = .unlessEditing
    }
}

class _EurekaFillableAndActionableRow: FieldRow<EurekaFillableAndActionableCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    override func updateCell() {
        super.updateCell()
        cell.textField.clearButtonMode = .whileEditing
        cell.textField.rightViewMode = .unlessEditing
    }
}

final class EurekaFillableAndActionableRow: _EurekaFillableAndActionableRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
