//
//  SimItemGroup.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import SwiftUI

struct SimItemGroup: View {
    let item            : PresentationItem
    @Binding var state  : PresentationState
    @State private var isExpanded   = false
    
    var children        : [PresentationItem]? {
        guard var items    = item.children else { return nil }

        if state.filter.contains(.withApps) {
            items = items.filter { $0.containsType(SimApp.self) }
        }
        if state.filter.contains(.runtimeInstalled) {
            items = items.filter {
                guard let runtime = $0.underlying as? SimRuntime else { return true }
                
                return runtime.isAvailable
            }
        }
        if !state.searchTerm.isEmpty {
            items = items.filter { $0.titlesContain(state.searchTerm) }
        }
        
        return items.isEmpty ? nil : items
    }
    
    var body: some View {
        if let childItems = children {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    ForEach(childItems) { childItem in
                        SimItemGroup(item: childItem, state: $state)
                    }
                },
                label: { SimItemNavLink(item: item) }
            )
        }
        else {
            SimItemNavLink(item: item)
        }
    }
}

struct SimItemGroup_Previews: PreviewProvider {
    static var simModel = SimModel()
    @State static var state = PresentationState()

    static var previews: some View {
        let testItem = state.presentationItems(from: simModel)[0]
        
        SimItemGroup(item: testItem, state: $state)
    }
}
