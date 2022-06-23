//
//  SourceItemGroup.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct SourceItemGroup<Item: SourceItem>: View {
    @State private var isExpanded = false
    @Binding var selection: UUID?

    var item   : Item

    var body: some View {
        if let childItems = item.children, childItems.count > 0 {
            DisclosureGroup(
                isExpanded: $isExpanded) {
                    ForEach(childItems) { childItem in
                        SourceItemGroup<Item.Child>(selection: $selection, item: childItem)
                    }
                } label: {
                    SourceItemLink(selection: $selection, item: item)
                }
                
        }
        else {
            SourceItemLink(selection: $selection, item: item)
        }
    }
}

struct SourceItemGroup_Previews: PreviewProvider {
    @State static var selection : UUID?
    static var state = SourceState(model: SimModel())
    static var sampleItem = state.deviceStyleItems()[0]

    static var previews: some View {
        SourceItemGroup(selection: $selection, item: sampleItem)
    }
}
