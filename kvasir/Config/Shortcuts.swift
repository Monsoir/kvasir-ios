//
//  Shortcuts.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let PingFangSCLightFont = UIFont(name: "PingFangSC-Light", size: 20)
let PingFangSCRegularFont = UIFont(name: "PingFangSC-Regular", size: 20)

let MainQueue = DispatchQueue.main
let GlobalUserInitiatedDispatchQueue = DispatchQueue.global(qos: .userInitiated)
let GlobalUserInteractiveDispatchQueue = DispatchQueue.global(qos: .userInteractive)
let GlobalDefaultDispatchQueue = DispatchQueue.global(qos: .default)

enum SystemDirectories {
    case document
    case caches
    case library
    case tmp
    
    var url: URL? {
        switch self {
        case .document:
            return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .library:
            return try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .caches:
            return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .tmp:
            return FileManager.default.temporaryDirectory
        }
    }
}
