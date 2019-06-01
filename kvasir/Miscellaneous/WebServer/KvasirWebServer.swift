//
//  KvasirWebServer.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import GCDWebServer

protocol KvasirWebServerVerbable {
    var verb: String { get }
}

protocol KvasirWebServerPathable {
    var path: String { get }
}

class KvasirWebServer {
    private(set) lazy var engine = GCDWebServer()
}

// MARK: - 公开方法
extension KvasirWebServer {
    func startServer(completion: (_: Bool, _: URL?) -> Void) {
        setupHandlers()
        
        let opened = engine.start(withPort: UInt(AppConstants.WebServer.port), bonjourName: nil)
        completion(opened, {
            var url: URL?
            
            url = engine.serverURL
            
            #if targetEnvironment(simulator)
            url = URL(string: "http://localhost:\(AppConstants.WebServer.port)")
            #endif
            
            return url
        }())
    }
    
    func stopServer() {
        engine.stop()
    }
}

// MARK: - 私有方法
private extension KvasirWebServer {
    func setupHandlers() {
//        setupDefaultHandlers()
        setupStaticSiteHandler()
        setupDynamicResourceHandlers()
    }
    
    func setupDefaultHandlers() {
        engine.addDefaultHandler(forMethod: KvasirWebServerVerb.get.verb, request: GCDWebServerRequest.self) { (request, completionBlock) in
            GlobalDefaultDispatchQueue.async {
                let response = GCDWebServerDataResponse(jsonObject: ["hello": "there"])
                completionBlock(response)
            }
        }
    }
    
    func setupStaticSiteHandler() {
        engine.addGETHandler(
            forBasePath: "/",
            directoryPath: AppConstants.WebServer.websiteLocation?.droppedScheme()?.absoluteString ?? "",
            indexFilename: "index.html",
            cacheAge: 3600,
            allowRangeRequests: true
        )
    }
    
    func setupDynamicResourceHandlers() {
        let restApis: [(KvasirWebServerVerbable, KvasirWebServerPathable, GCDWebServerAsyncProcessBlock)] = [
            (KvasirWebServerVerb.get, KvasirWebServerPath.test, KvasirWebServerHandlers.test)
        ]
        
        restApis.forEach {
            engine.bindVerb($0.0, to: $0.1, with: $0.2)
        }
    }
}

private extension GCDWebServer {
    func bindVerb(_ verb: KvasirWebServerVerbable, to path: KvasirWebServerPathable, with handler: @escaping GCDWebServerAsyncProcessBlock) {
        assert(path.path.hasPrefix("/"), "path should start with `/`")
        addHandler(forMethod: verb.verb, path: path.path, request: GCDWebServerRequest.self, asyncProcessBlock: handler)
    }
}
