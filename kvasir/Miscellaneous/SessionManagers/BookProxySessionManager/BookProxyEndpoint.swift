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
    
    private static let baseURL = BookProxySensitive.server
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case let .search(isbn):
                return ("/books/query", ["isbn": isbn])
            }
        }()
        
        let url = try type(of: self).baseURL.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}

fileprivate extension Dictionary where Key == String, Value == String  {
    var queryString: [URLQueryItem] {
        var output = [URLQueryItem]()
        for (key, value) in self {
            output.append(URLQueryItem(name: key, value: value))
        }
        return output
    }
}
