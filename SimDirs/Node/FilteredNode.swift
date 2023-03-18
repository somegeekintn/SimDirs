//
//  FilteredNode.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/3/23.
//

import SwiftUI
import Combine

class FilteredNode<T: Node>: Node, ObservableObject {
    typealias FilteredList = [FilteredNode<T.Child>]
    
    @Published var filtered : Bool
    @Published var isExpanded = false
    @Published var items : FilteredList?

    var wrappedNode : T
    var title       : String { wrappedNode.title }
    var headerTitle : String { wrappedNode.headerTitle }
    var header      : some View { wrappedNode.header }
    var content     : some View { wrappedNode.content }
    var children    : FilteredList { items ?? [] }
    
    init(_ node: T) {
        self.wrappedNode = node
        self.filtered = false
        
        self.items = node.items?.asFilteredNodes()
    }
    
    func icon(forHeader: Bool) -> some View {
        wrappedNode.icon(forHeader: forHeader)
    }
    
    func toggleExpanded(_ expanded: Bool? = nil, deep: Bool) {
        isExpanded = expanded ?? !isExpanded
        
        if deep {
            for child in children {
                child.toggleExpanded(isExpanded, deep: true)
            }
        }
    }

    func matchesFilter(_ filter: SourceFilter, inherited options: SourceFilter.Options) -> Bool {
        wrappedNode.matchesFilter(filter, inherited: options)
    }
    
    func matchedFilterOptions() -> SourceFilter.Options {
        return wrappedNode.matchedFilterOptions()
    }
    
    @discardableResult
    func applyFilter(_ filter: SourceFilter, inheriting options: SourceFilter.Options = []) -> Bool {
        let updatedOptions  = options.union(matchedFilterOptions())
        let childMatch      = children.reduce(false) { result, node in
                                node.applyFilter(filter, inheriting: updatedOptions) || result    // deliberately not short circuiting here
                            }
        let nodeMatch       = childMatch || wrappedNode.matchesFilter(filter, inherited: updatedOptions)
        
        filtered = !nodeMatch
        
        return nodeMatch
    }

    @discardableResult
    func processUpdate(_ update: SimModel.Update) -> Bool {
        if wrappedNode.processUpdate(update) {
            items = wrappedNode.items?.asFilteredNodes()
        }

        if let items {
            for node in items {
                node.processUpdate(update)
            }
        }
        
        return false
    }
}

extension Array where Element: Node {
    func asFilteredNodes() -> [FilteredNode<Element>] {
        self.map { FilteredNode($0) }
    }
}

