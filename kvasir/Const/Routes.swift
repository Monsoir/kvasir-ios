//
//  Routes.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

let KvasirNavigator = Navigator()

private struct Const {
    static let kvasir = "kvasir"
    static let digest = "digest"
}

class SchemaBuilder {
    private var schema: String
    
    init(schema: String = Const.kvasir) {
        self.schema = "\(schema):/"
    }
    
    func component(_ aComponent: String) -> SchemaBuilder {
        if aComponent.isEmpty { fatalError("route component should not be empty") }
        schema.append(contentsOf: "/\(aComponent)")
        return self
    }
    
    func extract() -> String {
        return schema
    }
}

struct KvasirURLs {
    // kvasir://digest/new/sentence
    static let newSentence = SchemaBuilder().component(Const.digest).component("new").component(DigestType.sentence.toMachine).extract()
    static let newParagraph = SchemaBuilder().component(Const.digest).component("new").component(DigestType.paragraph.toMachine).extract()
    
    // kvasir://digest/all/sentence
    static let allSentences = SchemaBuilder().component(Const.digest).component("all").component(DigestType.sentence.toMachine).extract()
    static let allParagraphs = SchemaBuilder().component(Const.digest).component("all").component(DigestType.paragraph.toMachine).extract()
    
    // kvasir://digest/sentence/an-id
    static let detailSentenceTemplate = SchemaBuilder().component(Const.digest).component(DigestType.sentence.toMachine).component("<string:id>").extract()
    static let detailSentence = { (id: String) -> String in
        return "\(SchemaBuilder().component(Const.digest).component(DigestType.sentence.toMachine).component(id).extract())"
    }
    static let detailParagraphTemplate = SchemaBuilder().component(Const.digest).component(DigestType.paragraph.toMachine).component("<string:id>").extract()
    static let detailParagraph = { (id: String) -> String in
        return "\(SchemaBuilder().component(Const.digest).component(DigestType.paragraph.toMachine).component(id).extract())"
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

private typealias RouteParams = (digestType: DigestType, createDigest: (() -> RealmWordDigest))
private let RouteParamsDict: [String: RouteParams] = [
    DigestType.sentence.toMachine: (.sentence, { return RealmSentence() }),
    DigestType.paragraph.toMachine: (.paragraph, { return RealmParagraph() }),
]

private func newDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    guard let param = RouteParamsDict[identifier] else { return nil }
    return WordDigestInfoViewController(digestType: param.digestType, digest: param.createDigest(), creating: true)
}

private func allDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    guard let param = RouteParamsDict[identifier] else { return nil }
    return TextListViewController(type: param.digestType)
}

private func detailDigestControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 1) else { return nil }
    guard let param = RouteParamsDict[identifier] else { return nil }
    guard let id = values["id"] as? String else { return nil }
    return TextDetailViewController(mode: .local, digestType: param.digestType, digestId: id)
}

private func get(url: URLConvertible, componentAt index: Int) -> String? {
    guard let url = url.urlValue else { return nil }
    let components = url.pathComponents
    return components.item(at: index)
}
