//
//  Kingfisher.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import Kingfisher

struct MsrKingfisher: ImageDownloadRedirectHandler {
    func handleHTTPRedirection(for task: SessionDataTask, response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(newRequest)
    }
}
