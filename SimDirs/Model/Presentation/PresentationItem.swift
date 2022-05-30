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
    var imageColor  : Color? { get }
    var contentView : AnyView? { get }
}

extension PresentableItem {
    var imageColor  : Color? { return nil }
    var contentView : AnyView? { return nil }
}

struct PresentationItem: Identifiable {
    let underlying  : PresentableItem
    var children    : [PresentationItem]?
    var id          : String
    var customImage : String?
    
    var title       : String { return underlying.title }
    var imageName   : String { return customImage ?? underlying.imageName }
    var imageColor  : Color { return underlying.imageColor ?? .white }
    var contentView : AnyView { return underlying.contentView ?? AnyView(Text(title)) }
    
    init(_ presentable: PresentableItem, image: String? = nil, identifier: String? = nil) {
        underlying = presentable
        id = identifier ?? underlying.id
        customImage = image
    }
}
