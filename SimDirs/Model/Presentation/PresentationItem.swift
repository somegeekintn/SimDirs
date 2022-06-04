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
    
    func filtered(_ filter: PresentationFilter) -> Self {
        guard var childItems    = self.children, !filter.isEmpty else { return self }
        var filteredItem        = self
        
        if filter.contains(.withApps) {
            childItems = childItems.filter { $0.containsType(SimApp.self) }
        }
        if filter.contains(.runtimeInstalled) {
            childItems = childItems.filter {
                guard let runtime = $0.underlying as? SimRuntime else { return true }
                
                return runtime.isAvailable
            }
        }
        filteredItem.children = childItems.isEmpty ? nil : childItems.map { $0.filtered(filter)}
        
        return filteredItem
    }
        
    func containsType<T> (_ type: T.Type) -> Bool {
        return underlying is T || children?.contains(where: { $0.containsType(type)}) ?? false
    }
}
