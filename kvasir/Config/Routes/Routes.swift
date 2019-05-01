//
//  Routes.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

struct KvasirURLs {
    // kvasir://digest/new/sentence
    static let newSentence = SchemaBuilder().component(RouteConstants.digest).component("new").component(RealmSentence.toMachine()).extract()
    static let newParagraph = SchemaBuilder().component(RouteConstants.digest).component("new").component(RealmParagraph.toMachine()).extract()
    
    // kvasir://digest/all/sentence
    static let allSentences = SchemaBuilder().component(RouteConstants.digest).component("all").component(RealmSentence.toMachine()).extract()
    static let allParagraphs = SchemaBuilder().component(RouteConstants.digest).component("all").component(RealmParagraph.toMachine()).extract()
    
    // kvasir://digest/sentence/an-id
    static let detailSentenceTemplate = SchemaBuilder().component(RouteConstants.digest).component(RealmSentence.toMachine()).component("<string:id>").extract()
    static let detailSentence = { (id: String) -> String in
        return "\(SchemaBuilder().component(RouteConstants.digest).component(RealmSentence.toMachine()).component(id).extract())"
    }
    static let detailParagraphTemplate = SchemaBuilder().component(RouteConstants.digest).component(RealmParagraph.toMachine()).component("<string:id>").extract()
    static let detailParagraph = { (id: String) -> String in
        return "\(SchemaBuilder().component(RouteConstants.digest).component(RealmParagraph.toMachine()).component(id).extract())"
    }
}

struct URLNavigaionMap {
    static func initialize(navigator: NavigatorType) {
        navigator.register(KvasirURLs.newSentence, newDigestControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.newParagraph, newDigestControllerFactory(url:values:context:))
        
        navigator.register(KvasirURLs.allSentences, allDigestControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.allParagraphs, allDigestControllerFactory(url:values:context:))
        
        navigator.register(KvasirURLs.detailSentenceTemplate, detailDigestControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.detailParagraphTemplate, detailDigestControllerFactory(url:values:context:))
    }
}

private typealias RouteParams = (createDigest: (() -> RealmWordDigest), holder: String)
private let RouteParamsDict: [String: RouteParams] = [
    DigestType.sentence.toMachine: ({ return RealmSentence() }, ""),
    DigestType.paragraph.toMachine: ({ return RealmParagraph() }, ""),
]

private func newDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    guard let param = RouteParamsDict[identifier] else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine():
        return CreateDigestContainerViewController(digest: param.createDigest() as! RealmSentence)
    case RealmParagraph.toMachine():
        return CreateDigestContainerViewController(digest: param.createDigest() as! RealmParagraph)
    default:
        return nil
    }
}

private func allDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine():
        return DigestListViewController<RealmSentence>()
    case RealmParagraph.toMachine():
        return DigestListViewController<RealmParagraph>()
    default:
        return nil
    }
}

private func detailDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 1) else { return nil }
    guard let id = values["id"] as? String else { return nil }
    
    switch identifier {
    case RealmSentence.toMachine():
        return DigestDetailViewController<RealmSentence>(digestId: id)
    case RealmParagraph.toMachine():
        return DigestDetailViewController<RealmParagraph>(digestId: id)
    default:
        return nil
    }
}

private func get(url: URLConvertible, componentAt index: Int) -> String? {
    guard let url = url.urlValue else { return nil }
    let components = url.pathComponents
    return components.item(at: index)
}
