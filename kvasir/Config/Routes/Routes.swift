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
    static let newSentence = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.new).component(RealmSentence.toMachine()).extract()
    static let newParagraph = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.new
        ).component(RealmParagraph.toMachine()).extract()
    
    // kvasir://digest/all/sentence
    static let allSentences = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.all).component(RealmSentence.toMachine()).extract()
    static let allParagraphs = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.all).component(RealmParagraph.toMachine()).extract()
    
    // kvasir://digest/sentence/an-id
    static let detailSentenceTemplate = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component("<string:id>").extract()
    static let detailSentence = { (id: String) -> String in
        return "\(SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(id).extract())"
    }
    static let detailParagraphTemplate = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component("<string:id>").extract()
    static let detailParagraph = { (id: String) -> String in
        return "\(SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(id).extract())"
    }
    
    /// 资源列表查看
    
    // kvasir://resource/all/book
    static let allBooks = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.book).extract()
    // kvasir://resource/book/an-id - for detail
    
    // kvasir://resource/all/author
    static let allAuthors = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.author).extract()
    // kvasir://resource/author/author-id/books
    static let booksOfAnAuthorTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.author).component("<string:id>").component(RouteConstants.Nouns.books).extract()
    static let booksOfAnAuthor = { (authorId: String) -> String in
        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.author).component(authorId).component(RouteConstants.Nouns.books).extract()
    }
    
    // kvasir://resource/all/translator
    static let allTranslators = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.translator).extract()
    // kvasir://resource/translator/translator-id/books
    static let booksOfATranslatorTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.translator).component("<string:id>").component(RouteConstants.Nouns.books).extract()
    static let booksOfATranslator = { (translatorId: String) -> String in
        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.translator).component(translatorId).component(RouteConstants.Nouns.books).extract()
    }
    
    /// 资源列表选择
    
    // kvasir://resource/select/book
    static let selectBooks = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.book).extract()
    
    // kvasir://resource/select/author
    static let selectAuthors = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.author).extract()
    
    // kvasir://resource/select/translator
    static let selectTranslators = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.translator).extract()
    
    // 某本书籍下的摘要列表
    
    // kvasir://resource/book/<book-id>/digest/sentence/all
    static let sentencesOfBookTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.book).component("<string:id>").component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(RouteConstants.Actions.all).extract()
    static let sentencesOfBook = { (_ bookId: String) -> String in
    return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.book).component(bookId).component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(RouteConstants.Actions.all).extract()
    }
    // kvasir://resource/book/<book-id>/digest/paragraph/all
    static let paragraphsOfBookTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.books).component("<string:id>").component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(RouteConstants.Actions.all).extract()
    static let paragraphsOfBook = { (_ bookId: String) -> String in
        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.books).component(bookId).component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(RouteConstants.Actions.all).extract()
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
        
        navigator.register(KvasirURLs.allBooks, allResourceControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.allAuthors, allResourceControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.allTranslators, allResourceControllerFactory(url:values:context:))
        
        navigator.register(KvasirURLs.booksOfAnAuthorTemplate, booksOfCreatorControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.booksOfATranslatorTemplate, booksOfCreatorControllerFactory(url:values:context:))
        
        navigator.register(KvasirURLs.selectBooks, selectResourceControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.selectAuthors, selectResourceControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.selectTranslators, selectResourceControllerFactory(url:values:context:))
        
        navigator.register(KvasirURLs.sentencesOfBookTemplate, digestOfBookControllerFactory(url:values:context:))
        navigator.register(KvasirURLs.paragraphsOfBookTemplate, digestOfBookControllerFactory(url:values:context:))
    }
}

// MARK: Controller Factory

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
        return DigestListViewController<RealmSentence>(with: [:])
    case RealmParagraph.toMachine():
        return DigestListViewController<RealmParagraph>(with: [:])
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

private func allResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RouteConstants.Nouns.book:
        return BookListViewController(with: ["editable": true, "title": "收集的书籍"])
    case RouteConstants.Nouns.author:
        return AuthorListViewController(with: ["editable": true, "title": "已知\(RealmAuthor.toHuman())", "creatorType": "author"])
    case RouteConstants.Nouns.translator:
        return TranslatorListViewController(with: ["editable": true, "title": "已知\(RealmTranslator.toHuman())", "creatorType": "translator"])
    default:
        return nil
    }
}

private func booksOfCreatorControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"] else { return nil }
    let creatorType = get(url: url, componentAt: 1) ?? "author"
    
    switch creatorType {
    case "author":
        return BookListViewController(with: ["editable": true, "title": "TA 的书籍", "creatorType": "author", "creatorId": id])
    case "translator":
        return BookListViewController(with: ["editable": true, "title": "TA 的书籍", "creatorType": "translator", "creatorId": id])
    default:
        return nil
    }
}

private func selectResourceControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let identifier = get(url: url, componentAt: 2) else { return nil }
    
    switch identifier {
    case RouteConstants.Nouns.book:
        return BookListViewController(with: ["editable": false, "title": "选择一本书籍"])
    case RouteConstants.Nouns.author:
        return AuthorListViewController(with: ["editable": false, "title": "选择一个\(RealmAuthor.toHuman())"])
    case RouteConstants.Nouns.translator:
        return TranslatorListViewController(with: ["editable": false, "title": "选择一个\(RealmTranslator.toHuman())"])
    default:
        return nil
    }
}

private func digestOfBookControllerFactory(url: URLConvertible, values: [String: Any], context: Any?) -> UIViewController? {
    guard let id = values["id"], let digestType = get(url: url, componentAt: 4) else { return nil }
    switch digestType {
    case RealmSentence.toMachine():
        return DigestListViewController<RealmSentence>(with: ["bookId": id])
    case RealmParagraph.toMachine():
        return DigestListViewController<RealmParagraph>(with: ["bookId": id])
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
