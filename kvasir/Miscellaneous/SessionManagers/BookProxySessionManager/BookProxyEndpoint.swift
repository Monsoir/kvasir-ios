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
    case ocr
    
    private static let baseURL = ProxySensitive.server
    
    var path: String {
        switch self {
        case .search(isbn: _):
            return "/books/query"
        case .ocr:
            return "/ocr"
        }
    }
    
    var absolutePath: String {
        return URL(string: ProxySensitive.server)?.appendingPathComponent(path).absoluteString ?? ""
    }
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters, headers: [String: String]) = {
            switch self {
            case let .search(isbn):
                let query = ["isbn": isbn]
                let headers = ProxySessionManager.authenticationHeaders(with: query)
                return (path, query, headers)
            case .ocr:
                return (path, [:], [:])
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

