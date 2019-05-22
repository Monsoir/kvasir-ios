//
//  BookProxySession.swift
//  kvasir
//
//  Created by Monsoir on 5/13/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Alamofire
import SwifterSwift

class ProxySessionManager {
    static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    private init() {}
    
    static func authenticationHeaders(with payload: [String: Any]) -> [String: String] {
        let timestamp = Date().iso8601String
        return [
            "authorization": "\(payload.queryString)-\(timestamp)-\(ProxySensitive.appSecret)".msr.md5Base64,
            "timestamp": timestamp,
        ]
    }
}

private extension Dictionary {
    var queryString: String {
        var components = URLComponents()
        components.queryItems = self.map({ (arg) -> URLQueryItem in
            let (key, value) = arg
            return URLQueryItem(name: key as! String, value: value as? String)
        })
        return "\(components.url?.absoluteString.dropFirst()  ?? "")"
    }
}
