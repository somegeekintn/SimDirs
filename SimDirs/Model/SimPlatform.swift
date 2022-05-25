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
}

extension SimPlatform: PresentableItem {
    var title       : String { return self.rawValue }
    var id          : String { return self.rawValue }
    var imageName   : String {
        switch self {
            case .iOS:      return "iphone"
            case .tvOS:     return "appletv"
            case .watchOS:  return "applewatch"
        }
    }
}
