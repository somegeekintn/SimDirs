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
    var icon        : NSImage? { get }
    var imageName   : String { get }
    var imageColor  : Color? { get }
    var contentView : AnyView? { get }
}

extension PresentableItem {
    var imageColor  : Color? { return nil }
    var icon        : NSImage? { return nil }
    var contentView : AnyView? { return nil }
}

struct PresentationItem: Identifiable {
    let underlying  : PresentableItem
    var children    : [PresentationItem]?
    var id          : String
    var customImage : String?
    
    var title       : String { return underlying.title }
    var navTitle    : String { return "\(typeName): \(underlying.title)" }
    var icon        : NSImage? { return underlying.icon }
    var imageName   : String { return customImage ?? underlying.imageName }
    var imageColor  : Color { return underlying.imageColor ?? .white }
    var contentView : AnyView { return underlying.contentView ?? AnyView(Text(title)) }
    var flattened   : [PresentationItem] { return [self] + (self.children?.flatMap { $0.flattened } ?? []) }
    var typeName    : String {
        switch underlying {
            case is SimPlatform:        return "Platform"
            case is SimProductFamily:   return "Product Family"
            case is SimRuntime:         return "Runtime"
            case is SimDeviceType:      return "Device Type"
            case is SimDevice:          return "Device"
            case is SimApp:             return "App"
            default:                    return "Item"
        }
    }
    
    init(_ presentable: PresentableItem, image: String? = nil, identifier: String? = nil) {
        underlying = presentable
        id = identifier ?? underlying.id
        customImage = image
    }
    
    func titlesContain(_ searchTerm: String) -> Bool {
        return title.contains(searchTerm) || children?.contains(where: { $0.titlesContain(searchTerm)}) ?? false
    }
    
    func containsType<T>(_ type: T.Type) -> Bool {
        return underlying is T || children?.contains(where: { $0.containsType(type)}) ?? false
    }
}

extension Array where Element == PresentationItem {
    var flatItems           : [PresentationItem] { self.flatMap { $0.flattened } }

    func itemsOf<T> (type: T.Type) -> [T] {
        return flatItems.compactMap { $0.underlying as? T }
    }

    func validateItems() {
        let allIDs = flatItems.map { $0.id }
        var idSet   = Set<String>()
        
        print("Validating \(allIDs.count) items")
        for id in allIDs {
            if !idSet.insert(id).inserted {
                print("Duplicate PresentationItem.id: \(id)")
            }
        }
    }

    func dumpPresentation(level: Int = 0) {
        let ident   = Array<String>(repeating: "\t", count: level).joined()
        
        for item in self {
            print("\(ident)\(item.title) [\(item.id)]")
            
            if let children = item.children {
                children.dumpPresentation(level: level + 1)
            }
        }
    }
}
