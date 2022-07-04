//
//  SourceItemData.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/15/22.
//

import SwiftUI

protocol SourceItemData {
    associatedtype Content  : View
    associatedtype Header   : View
    
    @ViewBuilder var header     : Self.Header { get }
    @ViewBuilder var content    : Self.Content { get }

    var title           : String { get }
    var headerTitle     : String { get }
    var imageDesc       : SourceImageDesc { get }

    var optionTrait     : SourceFilter.Options { get }
}

extension SourceItemData {
    var headerTitle     : String { title }
    var imageDesc       : SourceImageDesc { .symbol() }

    var header          : some View { get { EmptyView() } }
    var content         : some View { get { EmptyView() } }
    
    var optionTrait     : SourceFilter.Options { [] }
}

enum SourceImageDesc {
    case icon(nsImage: NSImage)
    case symbol(systemName: String = "questionmark.circle", color: Color = .primary)
    
    func withColor(_ color: Color) -> Self {
        switch self {
            case .icon:                 return self
            case let .symbol(name, _):  return .symbol(systemName: name, color: color)
        }
    }
}

struct SourceItemDataNone: SourceItemData {
    static let none     = SourceItemDataNone()
    
    var title           : String { "" }
}
