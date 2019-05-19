//
//  Routes.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

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
