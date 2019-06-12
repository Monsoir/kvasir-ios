//
//  Theme.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct ThemeConst {
    static let outlineColor = "#000000"
    static let mainBackgroundColor = "#FFFFFF"
    static let secondaryBackgroundColor = "#F4F3F4"
    static let appleBlue = "#006FFF"
}

enum FinderTagColor: CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
}

extension FinderTagColor {
    var initialId: String {
        return "kvasir-\(colorValue)"
    }
    
    var colorValue: String {
        switch self {
        case .red:
            return "F55C59"
        case .orange:
            return "F5A250"
        case .yellow:
            return "F6CD56"
        case .green:
            return "56CE67"
        case .blue:
            return "4290F4"
        case .purple:
            return "B173D2"
        case .gray:
            return "9D9DA0"
        }
    }
    
    var hexColor: String {
        return "#\(colorValue)"
    }
    
    var initialName: String {
        switch self {
        case .red:
            return "red"
        case .orange:
            return "orange"
        case .yellow:
            return "yellow"
        case .green:
            return "green"
        case .blue:
            return "blue"
        case .purple:
            return "purple"
        case .gray:
            return "gray"
        }
    }
}
