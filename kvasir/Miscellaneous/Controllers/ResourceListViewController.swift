//
//  ResourceListViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class ResourceListViewController: UnifiedViewController, Configurable {
    
    private(set) var configuration: Configurable.Configuration
    
    /// 是否可以新增，默认为 false
    var canAdd: Bool {
        return configuration["canAdd"] as? Bool ?? false
    }
    
    /// 列表是否可编辑，默认为 false
    var modifyable: Bool {
        return configuration["editable"] as? Bool ?? false
    }
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
