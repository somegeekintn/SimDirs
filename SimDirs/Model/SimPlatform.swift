//
//  SimPlatform.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import Foundation

enum SimPlatform: String, Decodable {
    case iOS
    case tvOS
    case watchOS

    static let presentation    : [SimPlatform] = [.iOS, .watchOS, .tvOS]
    
    var symbolName  : String {
        switch self {
            case .iOS:      return "iphone"
            case .tvOS:     return "appletv"
            case .watchOS:  return "applewatch"
        }
    }
}

extension SimPlatform: SourceItemData {
    var title       : String { self.rawValue }
    var headerTitle : String { "Platform: \(title)" }
    var imageDesc   : SourceImageDesc { .symbol(systemName: symbolName) }
}
