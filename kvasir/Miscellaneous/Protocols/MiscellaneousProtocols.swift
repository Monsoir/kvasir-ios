//
//  MiscellaneousProtocols.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

protocol CreateCoordinatorable {
    func post(info: PostInfoScript) throws
    func create(completion: @escaping RealmCreateCompletion)
}
