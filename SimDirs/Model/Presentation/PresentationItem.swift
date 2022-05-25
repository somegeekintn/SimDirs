//
//  PresentationItem.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/25/22.
//

import SwiftUI

protocol PresentableItem {
    var title       : String { get }
    var id          : String { get }
    var imageName   : String { get }
}

protocol PresentableContent {
    associatedtype Content : View
    
    var view          : Content { get }
}

struct PresentationContent<T: PresentableContent> {
    let underlying  : T
}

struct PresentationItem: Identifiable {
    let underlying  : PresentableItem
    var children    : [PresentationItem]?
    var id          : String
    var customImage : String?
    
    var title       : String { return underlying.title }
    var imageName   : String { return customImage ?? underlying.imageName }
    
    init(_ presentable: PresentableItem, image: String? = nil, identifier: String? = nil) {
        underlying = presentable
        id = identifier ?? underlying.id
        customImage = image
    }
}
