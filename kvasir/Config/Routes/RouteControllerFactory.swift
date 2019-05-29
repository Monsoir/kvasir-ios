//
//  RouteControllerFactory.swift
//  kvasir
//
//  Created by Monsoir on 5/19/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

func newDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine:
        let configuration: Configurable.Configuration = [
            "entity": RealmSentence(),
        ]
        return CreateDigestContainerViewController<RealmSentence>(configuration: mergingConfigurations(context as? [String: Any] ?? [:], configuration))
    case RealmParagraph.toMachine:
        let configuration: Configurable.Configuration = [
            "entity": RealmParagraph(),
        ]
        return CreateDigestContainerViewController<RealmParagraph>(configuration: mergingConfigurations(context as? [String: Any] ?? [:], configuration))
    default:
        return nil
    }
}

func newCreatorControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RealmAuthor.toMachine:
        let configuration: Configurable.Configuration = [
            "entity": RealmAuthor(),
        ]
        return CreateCreatorViewController<RealmAuthor>(configuration: mergingConfigurations(context as? Configurable.Configuration ?? [:], configuration))
    case RealmTranslator.toMachine:
        let configuration: Configurable.Configuration = [
            "entity": RealmParagraph(),
        ]
        return CreateCreatorViewController<RealmTranslator>(configuration: mergingConfigurations(context as? Configurable.Configuration ?? [:], configuration))
    default:
        return nil
    }
}

func newBookControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    let method = get(url: url, componentAt: 3) ?? RouteConstants.Preps.manully
    
    switch method {
    case RouteConstants.Preps.manully:
        let configuration: Configurable.Configuration = [
            "entity": RealmBook(),
        ]
        return CreateBookViewController(configuration: mergingConfigurations(context as? Configurable.Configuration ?? [:], configuration))
    case RouteConstants.Preps.scanly:
        let configuration: Configurable.Configuration = [
            "mode": "remote",
        ]
        return BookDetailViewController(configuration: mergingConfigurations(context as? Configurable.Configuration ?? [:], configuration))
    default:
        return nil
    }
}

func allDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    let preDefined: Configurable.Configuration = [
        "canAdd": true,
    ]
    
    switch identifier {
    case RealmSentence.toMachine:
        return DigestListViewController<RealmSentence>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    case RealmParagraph.toMachine:
        return DigestListViewController<RealmParagraph>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    default:
        return nil
    }
}

func detailDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 1) else { return nil }
    guard let id = values["id"] as? String else { return nil }
    
    let preDefined: Configurable.Configuration = [
        "id": id,
    ]
    switch identifier {
    case RealmSentence.toMachine:
        return DigestDetailViewController<RealmSentence>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    case RealmParagraph.toMachine:
        return DigestDetailViewController<RealmParagraph>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    default:
        return nil
    }
}

func allResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    // common configs
    let preDefined: [String: Any] = [
        "editable": true,
    ]
    
    // configs will be merged by the extraContext
    switch identifier {
    case RouteConstants.Nouns.book:
        let extra: Configurable.Configuration = [
            "title": "收集的书籍",
            "placeholder": "右上角添加一本书籍吧",
        ]
        return BookListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], extra))
    case RouteConstants.Nouns.author:
        let extra: Configurable.Configuration = [
            "title": "已知\(RealmAuthor.toHuman)",
            "creatorType": "author",
        ]
        return AuthorListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], extra))
    case RouteConstants.Nouns.translator:
        let extra: Configurable.Configuration = [
            "title": "已知\(RealmTranslator.toHuman)",
            "creatorType": "translator",
        ]
        return TranslatorListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], extra))
    case RouteConstants.Nouns.tag:
        let extra: Configurable.Configuration = [
            "title": "已知\(RealmTag.toHuman)",
        ]
        return TagListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], extra))
    default:
        return nil
    }
}

func resourceDetailFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"] else { return nil }
    let resourceType = get(url: url, componentAt: 1) ?? RealmTag.toMachine
    
    let preDefined: [String: Any] = [
        "id": id,
    ]
    
    switch resourceType {
    case RouteConstants.Nouns.tag:
        return TagDetailViewController(with: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    case RouteConstants.Nouns.book:
        return BookDetailViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    default:
        return nil
    }
}

func booksOfCreatorControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"] else { return nil }
    let creatorType = get(url: url, componentAt: 1) ?? RouteConstants.Nouns.author
    
    let preDefined: [String: Any] = [
        "creatorId": id,
        "editable": true,
    ]
    
    switch creatorType {
    case RouteConstants.Nouns.author:
        return BookListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], ["creatorType": "author"]))
    case RouteConstants.Nouns.translator:
        return BookListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], ["creatorType": "translator"]))
    default:
        return nil
    }
}

func selectResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    let preDefined: [String: Any] = [
        "editable": false,
    ]
    
    switch identifier {
    case RouteConstants.Nouns.book:
        return BookListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], ["title": "选择一本书籍"]))
    case RouteConstants.Nouns.author:
        return AuthorListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], ["title": "选择一个\(RealmAuthor.toHuman)"]))
    case RouteConstants.Nouns.translator:
        return TranslatorListViewController(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:], ["title": "选择一个\(RealmTranslator.toHuman)"]))
    default:
        return nil
    }
}

func digestOfBookControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"], let digestType = get(url: url, componentAt: 4) else { return nil }
    
    let preDefined: [String: Any] = [
        "bookId": id,
    ]
    
    switch digestType {
    case RealmSentence.toMachine:
        return DigestListViewController<RealmSentence>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    case RealmParagraph.toMachine:
        return DigestListViewController<RealmParagraph>(configuration: mergingConfigurations(preDefined, context as? [String: Any] ?? [:]))
    default:
        return nil
    }
}

// MARK: Helpers

/// 合并配置项，并以最后的配置为准
///
/// - Parameter configurations: 若干个配置项
/// - Returns: 最终的配置
private func mergingConfigurations(_ configurations: Configurable.Configuration...) -> Configurable.Configuration {
    return configurations.reduce(configurations[0], { (acc, current) -> Configurable.Configuration in
        return acc.merging(current, uniquingKeysWith: { (_, new) in new })
    })
}

private func get(url: URLConvertible, componentAt index: Int) -> String? {
    guard let url = url.urlValue else { return nil }
    let components = url.pathComponents
    return components.item(at: index)
}
