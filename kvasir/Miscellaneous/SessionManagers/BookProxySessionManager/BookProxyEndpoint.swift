//
//  BookProxyEndpoint.swift
//  kvasir
//
//  Created by Monsoir on 5/13/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import SwifterSwift
import Alamofire

enum BookProxyEndpoint: URLRequestConvertible {
    case search(isbn: String)
    
    private static let baseURL = ProxySensitive.server
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters, headers: [String: String]) = {
            switch self {
            case let .search(isbn):
                let query = ["isbn": isbn]
                let headers = ProxySessionManager.authenticationHeaders(with: query)
                return ("/books/query", query, headers)
            }
        }()
        
        let url = try type(of: self).baseURL.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        var request = try URLEncoding.default.encode(urlRequest, with: result.parameters)
        
        // Add some headers
        result.headers.forEach { (arg) in
            let (key, value) = arg
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
