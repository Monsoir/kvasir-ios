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

protocol Configurable {
    typealias Configuration = [String: Any]
    init(configuration: Configuration)
}

protocol RealmNotificationable {
    var realmNotificationTokens: Set<NotificationToken> { get }
    func reclaim()
}

protocol CreateCoordinatorable: Configurable {
    func post(info: PostInfoScript) throws
    func create(completion: @escaping RealmCreateCompletion)
}

protocol UpdateCoordinatorable: Configurable {
    func put(info: PutInfoScript) throws
    func update(completion: @escaping RealmUpdateCompletion)
}

protocol ListQueryCoordinatorable: Configurable, RealmNotificationable {
    associatedtype Model: RealmBasicObject
    
    var initialHandler: ((_ results: Results<Model>?) -> Void)? { get set }
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)? { get set }
    var errorHandler: ((_ error: Error) -> Void)? { get set }
    
    func setupQuery(for section: Int)
}

protocol Namable: class {
    static var toHuman: String { get }
    static var toMachine: String { get }
}

protocol RealmDataBackupable {
    static var backupPath: URL? { get }
    static func createBackupOperation() -> ExportOperation?
}

protocol RealmDataRecoverable {
    static var recoverPath: URL? { get }
    static func createRecoverOperation() -> ImportOperation?
}
