//
//  Node.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/2/23.
//

import SwiftUI

protocol Node {
    associatedtype Icon: View
    associatedtype Header: View
    associatedtype Content: View
    associatedtype Child: Node
    
    var items                   : [Child]? { get set }

    var title                   : String { get }
    var headerTitle             : String { get }

    @ViewBuilder var header     : Header { get }
    @ViewBuilder var content    : Content { get }

    @ViewBuilder
    func icon(forHeader: Bool) -> Icon
    
    func matchedFilterOptions() -> SourceFilter.Options
    func matchesFilter(_ filter: SourceFilter, inherited options: SourceFilter.Options) -> Bool
    @discardableResult
    mutating func processUpdate(_ update: SimModel.Update) -> Bool
}

extension Node {
    var items       : [LeafNode]? { get { nil } set { } }
    
    @ViewBuilder
    func symbolIcon(_ systemName: String, color: Color? = nil, forHeader: Bool) -> some View {
        if forHeader {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 128, maxHeight: 128)
                .shadow(radius: 4.0, x: 2.0, y: 2.0)
        }
        else {
            Image(systemName: systemName)
                .foregroundColor(color ?? .primary)
                .symbolRenderingMode(.hierarchical)
        }
    }

    func callAsFunction<Item: Node>(emptyIsNil: Bool = false, @NodeListBuilder items: () -> [Item]) -> NodeLink<Self, Item> {
        link(emptyIsNil: emptyIsNil, to: items)
    }

    func link<Item: Node>(emptyIsNil: Bool = false, @NodeListBuilder to items: () -> [Item]) -> NodeLink<Self, Item> {
        NodeLink(self, emptyIsNil: emptyIsNil, items: items)
    }

    func matchedFilterOptions() -> SourceFilter.Options {
        return []
    }

    func matchesTerm(_ term: String) -> Bool {
        term.isEmpty || title.uppercased().contains(term.uppercased())
    }
    
    func matchesFilter(_ filter: SourceFilter, inherited options: SourceFilter.Options) -> Bool {
        filter.options.isSubset(of: options) && matchesTerm(filter.searchTerm)
    }
    
    @discardableResult
    mutating func processUpdate(_ update: SimModel.Update) -> Bool {
        return false
    }
}

/// Defines the requirements of a collection that can serve as a `NodeList`.

protocol NodeList: RandomAccessCollection where Self.Element: Node, Index: Hashable { }

extension NodeList {
    @NodeListBuilder
    func linkEachTo<Item: Node>(emptyIsNil: Bool = false, @NodeListBuilder items: (Element) -> [Item]) -> [some Node] {
        map { item in
            item.link(emptyIsNil: emptyIsNil, to: { items(item) })
        }
    }
}

extension Array: NodeList where Element: Node { }

// MARK: - Special Nodes -

enum LeafNode: Node {
    var title       : String { "impossible" }
    var headerTitle : String { title }
    
    var header: some View { Text("impossible") }
    var content: some View { Text("impossible") }
    
    func icon(forHeader: Bool) -> some View {
        Text("impossible")
    }
}

struct RootNode<Item: Node>: Node {
    var items       : [Item]?
    var title       : String { "Root" }
    var headerTitle : String { title }
    var header      : some View { Text("Root") }
    var content     : some View { Text("Root") }

    init() {
        self.items = nil
    }

    init(@NodeListBuilder _ items: () -> [Item]) {
        self.items = items()
    }

    func icon(forHeader: Bool) -> some View {
        symbolIcon("tree", forHeader: forHeader)
    }
}

struct NodeLink<Base: Node, Item: Node>: Node {
    typealias UpdateHandler = (SimModel.Update) -> [Item]??

    var base            : Base
    var items           : [Item]?
    var title           : String { base.title }
    var headerTitle     : String { base.headerTitle }
    var header          : Base.Header { base.header }
    var content         : Base.Content { base.content }
    var updaterHandler  : UpdateHandler? = nil
    
    init(_ base: Base, emptyIsNil: Bool = false, @NodeListBuilder items: () -> [Item]) {
        let list = items()
        
        self.base = base
        self.items = emptyIsNil ? (list.isEmpty ? nil : list) : list
    }

    init(_ base: Base, emptyIsNil: Bool = false, items: [Item]) {
        self.base = base
        self.items = emptyIsNil ? (items.isEmpty ? nil : items) : items
    }

    func icon(forHeader: Bool) -> some View {
        base.icon(forHeader: forHeader)
    }

    func matchedFilterOptions() -> SourceFilter.Options {
        return base.matchedFilterOptions()
    }
    
    mutating func onUpdate(_ handler: @escaping UpdateHandler) -> Self {
        updaterHandler = handler
        
        return self
    }
    
    @discardableResult
    mutating func processUpdate(_ update: SimModel.Update) -> Bool {
        guard let newItems = updaterHandler?(update) else { return false }

        self.items = newItems

        return true
    }
}
