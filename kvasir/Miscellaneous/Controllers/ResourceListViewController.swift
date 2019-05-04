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
    
    convenience init(editable: Bool? = false) {
        self.init(nibName: nil, bundle: nil)
        if let editable = editable {
            self.editable = editable
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
