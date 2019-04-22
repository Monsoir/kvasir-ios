//
//  UIConst.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

struct ThemeConst {
    static let outlineColor = "#000000"
    static let mainBackgroundColor = "#FFFFFF"
    static let secondaryBackgroundColor = "##F4F3F4"
    static let functionalButtonContainerHeight = 50
}

let TextEditorFontName = "PingFangSC-Regular"
let DigestTitleLength = 40

enum DigestType {
    case sentence
    case paragraph
    
    var toMachine: String {
        get {
            switch self {
            case .sentence:
                return "sentence"
            case .paragraph:
                return "paragraph"
            }
        }
    }
    
    var toHuman: String {
        get {
            switch self {
            case .sentence:
                return "句子"
            case .paragraph:
                return "段落"
            }
        }
    }
}
