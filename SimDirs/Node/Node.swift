//
//  Node.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/2/23.
//

import SwiftUI

protocol Node: NodeSource {
    associatedtype Icon: View
    associatedtype Header: View
    associatedtype Content: View
    
    var title                   : String { get }
    var headerTitle             : String { get }

    @ViewBuilder var header     : Header { get }
    @ViewBuilder var content    : Content { get }

    @ViewBuilder
    func icon(forHeader: Bool) -> Icon
    
    func matchedFilterOptions() -> SourceFilter.Options
    func matchesFilter(_ filter: SourceFilter, inherited options: SourceFilter.Options) -> Bool
}

extension Node {
    var items       : [LeafNode]? {
        get { nil }
        set { }
    }

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
}

/// Indicates a type that owns a list of Nodes

protocol NodeSource {
    associatedtype List: NodeList

    var items    : List? { get set }
}

/// Defines the requirements of a collection that can serve as a `NodeList`.

protocol NodeList: RandomAccessCollection where Self.Element: Node, Index: Hashable { }

extension NodeList {
    @NodeListBuilder
    func linkEachTo<Item: Node>(emptyIsNil: Bool = false, @NodeListBuilder items: (Element) -> [Item]) -> some NodeList {
        map { item in
            item.link(emptyIsNil: emptyIsNil, to: { items(item) })
        }
// Makes compiler unhappy. resultBuilder probably incorrect
//        for item in self {
//            item.link(to: { items(item) })
//        }
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

    func icon(forHeader: Bool) -> some View { symbolIcon("tree", forHeader: forHeader) }
}

struct NodeLink<Base: Node, Item: Node>: Node {
    var base        : Base
    var items       : [Item]?
    var title       : String { base.title }
    var headerTitle : String { base.headerTitle }
    var header      : Base.Header { base.header }
    var content     : Base.Content { base.content }

    init(_ base: Base, emptyIsNil: Bool = false, @NodeListBuilder items: () -> [Item]) {
        let list = items()
        
        self.base = base
        self.items = emptyIsNil ? (list.isEmpty ? nil : list) : list
    }

@available(*, deprecated, message: "Consider using Root { items } instead")
    init(@NodeListBuilder _ items: () -> [Item]) where Base == RootNode<Item> {
        self.base = RootNode()
        self.items = items()
    }

    func icon(forHeader: Bool) -> some View {
        base.icon(forHeader: forHeader)
    }

    func matchedFilterOptions() -> SourceFilter.Options {
        return base.matchedFilterOptions()
    }
}
