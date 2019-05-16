//
//  BookProxySession.swift
//  kvasir
//
//  Created by Monsoir on 5/13/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Alamofire

class BookProxySessionManager {
    static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    private init() {}
}
