//
//  MiscellaneousProtocols.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

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
