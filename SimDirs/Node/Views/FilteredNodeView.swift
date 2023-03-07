//
//  FilteredNodeView.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/3/23.
//

import SwiftUI

struct FilteredNodeView<T: Node>: View {
    @StateObject var node   : FilteredNode<T>
    @Binding var filter     : SourceFilter
    
    init(_ node: T, filter: Binding<SourceFilter>) {
        self._node = StateObject(wrappedValue: FilteredNode(node))
        self._filter = filter
    }
    
    init<Item: Node>(filter: Binding<SourceFilter>, @NodeListBuilder items: () -> [Item]) where T == RootNode<Item> {
        self.init(RootNode(items), filter: filter)
    }

    var body: some View {
        Root(node: node)
            .searchable(text: $filter.searchTerm, placement: .sidebar)
            .onAppear { node.applyFilter(filter) }
            .onChange(of: filter) { node.applyFilter($0) }
    }
}

extension FilteredNodeView {
    struct Root: View {
        @ObservedObject var node    : FilteredNode<T>
        
        var visibleItems    : FilteredNode<T>.List { node.items.map { $0.filter { !$0.filtered} } ?? [] }

        var body: some View {
            let items = visibleItems
            
            List {
                if !items.isEmpty {
                    ForEach(items.indices, id: \.self) { index in
                        Item(node: items[index])
                    }
                }
                else {
                    Text("No Filter Results")
                }
            }
        }
    }

    struct ItemList<T: Node>: View {
        var items   : [FilteredNode<T>]
        
        init(items: [FilteredNode<T>]) {
            self.items = items
        }
        
        var body: some View {
            ForEach(items.indices, id: \.self) { index in
                Item(node: items[index])
            }
        }
    }

    struct Item<T: Node>: View {
        @ObservedObject var node    : FilteredNode<T>
        
        var body: some View {
            if !node.filtered {
                NodeLabel(node)
                
                if let items = node.items, node.isExpanded {
                    ItemList(items: items)
                        .padding(.leading, 12.0)
                }
            }
        }
    }
}

struct FilteredNodeView_Previews: PreviewProvider {
    @State static var filter    = SourceFilter.restore()
    
    static var previews: some View {
        List {
            FilteredNodeView(filter: $filter) {
                SimPlatform.iOS
                SimPlatform.tvOS
                SimPlatform.watchOS
            }
        }
    }
}
