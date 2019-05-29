//
//  RouteControllerFactory.swift
//  kvasir
//
//  Created by Monsoir on 5/19/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

private typealias RouteParams = (createDigest: (() -> RealmWordDigest), holder: String)
private let RouteParamsDict: [String: RouteParams] = [
    "\(RealmSentence.toMachine)": ({ return RealmSentence() }, ""),
    "\(RealmParagraph.toMachine)": ({ return RealmParagraph() }, ""),
]

func newDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    guard let param = RouteParamsDict[identifier] else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine:
        return CreateDigestContainerViewController(digest: param.createDigest() as! RealmSentence)
    case RealmParagraph.toMachine:
        return CreateDigestContainerViewController(digest: param.createDigest() as! RealmParagraph)
    default:
        return nil
    }
}

func allDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    var contextToPass = [String: Any]()
    if let context = context as? [String: Any] {
        contextToPass = contextToPass.merging(context, uniquingKeysWith: { (current, new) -> Any in
            return new
        })
    }
    switch identifier {
    case RealmSentence.toMachine:
        return DigestListViewController<RealmSentence>(configuration: contextToPass)
    case RealmParagraph.toMachine:
        return DigestListViewController<RealmParagraph>(configuration: contextToPass)
    default:
        return nil
    }
}

func detailDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 1) else { return nil }
    guard let id = values["id"] as? String else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine:
        return DigestDetailViewController<RealmSentence>(digestId: id)
    case RealmParagraph.toMachine:
        return DigestDetailViewController<RealmParagraph>(digestId: id)
    default:
        return nil
    }
}

func allResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    // common configs
    var preDefinedContext: [String: Any] = [
        "editable": true,
    ]
    
    // config passed from jump point
    if let context = context as? [String: Any] {
        preDefinedContext = preDefinedContext.merging(context, uniquingKeysWith: { (current, new) -> Any in
            return new
        })
    }
    
    // config to set in the `switch`
    var extraContext: [String: Any]
    
    // configs will be merged by the extraContext
    switch identifier {
    case RouteConstants.Nouns.book:
        extraContext = [
            "title": "收集的书籍",
        ]
        return BookListViewController(configuration: extraContext.merging(preDefinedContext, uniquingKeysWith: { (current, _) in current }))
    case RouteConstants.Nouns.author:
        extraContext = [
            "title": "已知\(RealmAuthor.toHuman)",
            "creatorType": "author",
        ]
        return AuthorListViewController(configuration: extraContext.merging(preDefinedContext, uniquingKeysWith: { (current, _) in current }))
    case RouteConstants.Nouns.translator:
        extraContext = [
            "title": "已知\(RealmTranslator.toHuman)",
            "creatorType": "translator",
        ]
        return TranslatorListViewController(configuration: extraContext.merging(preDefinedContext, uniquingKeysWith: { (current, _) in current }))
    case RouteConstants.Nouns.tag:
        extraContext = [
            "title": "已知\(RealmTag.toHuman)",
        ]
        return TagListViewController(configuration: extraContext.merging(preDefinedContext, uniquingKeysWith: { (current, _) in current }))
    default:
        return nil
    }
}

func resourceDetailFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"] else { return nil }
    let resourceType = get(url: url, componentAt: 1) ?? RealmTag.toMachine
    
    switch resourceType {
    case RouteConstants.Nouns.tag:
        return TagDetailViewController(with: [ "id": id ])
    default:
        return nil
    }
}

func booksOfCreatorControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"] else { return nil }
    let creatorType = get(url: url, componentAt: 1) ?? RouteConstants.Nouns.author
    
    switch creatorType {
    case RouteConstants.Nouns.author:
        return BookListViewController(configuration: ["editable": true, "title": "TA 的书籍", "creatorType": "author", "creatorId": id])
    case RouteConstants.Nouns.translator:
        return BookListViewController(configuration: ["editable": true, "title": "TA 的书籍", "creatorType": "translator", "creatorId": id])
    default:
        return nil
    }
}

func selectResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RouteConstants.Nouns.book:
        return BookListViewController(configuration: ["editable": false, "title": "选择一本书籍"])
    case RouteConstants.Nouns.author:
        return AuthorListViewController(configuration: ["editable": false, "title": "选择一个\(RealmAuthor.toHuman)"])
    case RouteConstants.Nouns.translator:
        return TranslatorListViewController(configuration: ["editable": false, "title": "选择一个\(RealmTranslator.toHuman)"])
    default:
        return nil
    }
}

func digestOfBookControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"], let digestType = get(url: url, componentAt: 4) else { return nil }
    switch digestType {
    case RealmSentence.toMachine:
        return DigestListViewController<RealmSentence>(configuration: ["bookId": id])
    case RealmParagraph.toMachine:
        return DigestListViewController<RealmParagraph>(configuration: ["bookId": id])
    default:
        return nil
    }
}

// MARK: Helpers

private func get(url: URLConvertible, componentAt index: Int) -> String? {
    guard let url = url.urlValue else { return nil }
    let components = url.pathComponents
    return components.item(at: index)
}
