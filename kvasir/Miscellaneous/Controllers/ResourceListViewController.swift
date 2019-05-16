//
//  ResourceListViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class ResourceListViewController: UIViewController {
    
    private(set) var editable = false
    private(set) var configuration: [String: Any]!
    
    init(with configuration: [String: Any]) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
