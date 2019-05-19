//
//  Routes.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

//struct KvasirURLs {
//    // kvasir://digest/new/sentence
//    static let newSentence = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.new).component(RealmSentence.toMachine()).extract()
//    static let newParagraph = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.new
//        ).component(RealmParagraph.toMachine()).extract()
//
//    // kvasir://digest/all/sentence
//    static let allSentences = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.all).component(RealmSentence.toMachine()).extract()
//    static let allParagraphs = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RouteConstants.Actions.all).component(RealmParagraph.toMachine()).extract()
//
//    // kvasir://digest/sentence/an-id
//    static let detailSentenceTemplate = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component("<string:id>").extract()
//    static let detailSentence = { (id: String) -> String in
//        return "\(SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(id).extract())"
//    }
//    static let detailParagraphTemplate = SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component("<string:id>").extract()
//    static let detailParagraph = { (id: String) -> String in
//        return "\(SchemaBuilder().component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(id).extract())"
//    }
//
//    /// 资源列表查看
//
//    // kvasir://resource/all/book
//    static let allBooks = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.book).extract()
//    // kvasir://resource/book/an-id - for detail
//
//    // kvasir://resource/all/author
//    static let allAuthors = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.author).extract()
//    // kvasir://resource/author/author-id/books
//    static let booksOfAnAuthorTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.author).component("<string:id>").component(RouteConstants.Nouns.books).extract()
//    static let booksOfAnAuthor = { (authorId: String) -> String in
//        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.author).component(authorId).component(RouteConstants.Nouns.books).extract()
//    }
//
//    // kvasir://resource/all/translator
//    static let allTranslators = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.all).component(RouteConstants.Nouns.translator).extract()
//    // kvasir://resource/translator/translator-id/books
//    static let booksOfATranslatorTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.translator).component("<string:id>").component(RouteConstants.Nouns.books).extract()
//    static let booksOfATranslator = { (translatorId: String) -> String in
//        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.translator).component(translatorId).component(RouteConstants.Nouns.books).extract()
//    }
//
//    /// 资源列表选择
//
//    // kvasir://resource/select/book
//    static let selectBooks = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.book).extract()
//
//    // kvasir://resource/select/author
//    static let selectAuthors = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.author).extract()
//
//    // kvasir://resource/select/translator
//    static let selectTranslators = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Actions.select).component(RouteConstants.Nouns.translator).extract()
//
//    // 某本书籍下的摘要列表
//
//    // kvasir://resource/book/<book-id>/digest/sentence/all
//    static let sentencesOfBookTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.book).component("<string:id>").component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(RouteConstants.Actions.all).extract()
//    static let sentencesOfBook = { (_ bookId: String) -> String in
//    return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.book).component(bookId).component(RouteConstants.Nouns.digest).component(RealmSentence.toMachine()).component(RouteConstants.Actions.all).extract()
//    }
//    // kvasir://resource/book/<book-id>/digest/paragraph/all
//    static let paragraphsOfBookTemplate = SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.books).component("<string:id>").component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(RouteConstants.Actions.all).extract()
//    static let paragraphsOfBook = { (_ bookId: String) -> String in
//        return SchemaBuilder().component(RouteConstants.Nouns.resource).component(RouteConstants.Nouns.books).component(bookId).component(RouteConstants.Nouns.digest).component(RealmParagraph.toMachine()).component(RouteConstants.Actions.all).extract()
//    }
//}

struct URLNavigaionMap {
    static func initialize(navigator: NavigatorType) {
        func registerRoute(url: KvasirURL) {
            navigator.register(url.template, url.controllerFactory)
        }
        
        registerRoute(url: .newSentence)
        registerRoute(url: .newParagraph)
        
        registerRoute(url: .allSentences)
        registerRoute(url: .allParagraphs)
        
        registerRoute(url: .detailSentence)
        registerRoute(url: .detailParagraph)
        
        registerRoute(url: .allBooks)
        registerRoute(url: .allAuthors)
        registerRoute(url: .allTranslators)
        
        registerRoute(url: .booksOfAnAuthor)
        registerRoute(url: .booksOfATranslator)
        
        registerRoute(url: .selectBooks)
        registerRoute(url: .selectAuthors)
        registerRoute(url: .selectTranslators)
        
        registerRoute(url: .sentencesOfBook)
        registerRoute(url: .paragraphsOfBook)
    }
}
