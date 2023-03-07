//
//  SimProductFamily.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import Foundation

enum SimProductFamily: String, Decodable {
    case appleTV = "Apple TV"
    case appleWatch = "Apple Watch"
    case iPad
    case iPhone

    static let presentation    : [SimProductFamily] = [.iPhone, .iPad, .appleWatch, .appleTV]

    var symbolName  : String {
        switch self {
            case .iPad:         return "ipad"
            case .iPhone:       return "iphone"
            case .appleTV:      return "appletv"
            case .appleWatch:   return "applewatch"
        }
    }
}
