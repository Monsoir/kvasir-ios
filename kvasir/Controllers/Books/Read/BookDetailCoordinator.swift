//
//  BookDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

typealias BookDetailQueryCompletion = (_ success: Bool, _ data: Any?, _ message: String?) -> Void

protocol BookDetailCoordinable: RealmNotificationable, Configurable {
    var mightAddedManully: Bool { get }
    var id: String { get }
    var thumbnail: String { get }
    var title: String { get }
    var authors: String { get }
    var detail: String { get }
    var summary: String { get }
    var binding: String { get }
    var isbn13: String { get }
    var isbn10: String { get }
    var originTitle: String { get }
    var pages: Int { get }
    var price: String { get }
    var publisher: String { get }
    var translators: String { get }
    var payloadForHeader: [String: Any] { get }
    
    var reload: ((_ entity: RealmBook?) -> Void)? { get set }
    var errorHandler: ((_ message: String) -> Void)? { get set }
    var entityDeleteHandler: (() -> Void)? { get set }
    
    func query(_ completion: @escaping BookDetailQueryCompletion)
}

class BookDetailCoordinator: BookDetailCoordinable {
    
    var mightAddedManully: Bool {
        return false
    }
    
    var id: String {
        return ""
    }
    
    var thumbnail: String {
        return ""
    }
    
    var title: String {
        return ""
    }
    
    var authors: String {
        return ""
    }
    
    var detail: String {
        return ""
    }
    
    var summary: String {
        return ""
    }
    
    var binding: String {
        return ""
    }
    
    var isbn13: String {
        return ""
    }
    
    var isbn10: String {
        return ""
    }
    
    var originTitle: String {
        return ""
    }
    
    var pages: Int {
        return 0
    }
    
    var price: String {
        return ""
    }
    
    var publisher: String {
        return ""
    }
    
    var translators: String {
        return ""
    }
    
    var payloadForHeader: [String: Any] {
        return [:]
    }
    
    var notificationToken: NotificationToken?
    
    var reload: ((RealmBook?) -> Void)?
    
    var errorHandler: ((String) -> Void)?
    
    var entityDeleteHandler: (() -> Void)?
    
    private(set) var configuraion: Configuration
    required init(configuration: Configuration) {
        self.configuraion = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func query(_ completion: @escaping BookDetailQueryCompletion) {
        completion(false, nil, "subclass must override `query` method")
    }
    
    func reclaim() {
        fatalError("subclass must override `reclaim` method")
    }
}
