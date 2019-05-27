//
//  MiscellaneousProtocols.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

typealias PostInfoScript = [String: Any?]
typealias PostInfo = [String: Any]

typealias PutInfoScript = [String: Any?]
typealias PutInfo = [String: Any]

protocol CreateCoordinatorable {
    func post(info: PostInfoScript) throws
    func create(completion: @escaping RealmCreateCompletion)
}

protocol UpdateCoordinatorable {
    func put(info: PutInfoScript) throws
    func update(completion: @escaping RealmUpdateCompletion)
}

protocol ListQueryCoordinatorable {
    associatedtype Model: RealmBasicObject
    
    var initialLoadHandler: ((_ results: Results<Model>?) -> Void)? { get set }
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)? { get set }
    var errorHandler: ((_ error: Error) -> Void)? { get set }
    
    init(with configuration: [String: Any]?)
    func reclaim()
    func setupQuery(for section: Int)
}
