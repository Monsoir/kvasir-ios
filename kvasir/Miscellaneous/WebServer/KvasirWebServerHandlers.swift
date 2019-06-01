//
//  KvasirWebServerHandlers.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import GCDWebServer

struct KvasirWebServerHandlers {
    static let test: GCDWebServerAsyncProcessBlock = { request, completionBlock in
        GlobalDefaultDispatchQueue.async {
            let reponse = GCDWebServerDataResponse(jsonObject: ["hello": "world again"])
            completionBlock(reponse)
        }
    }
}
