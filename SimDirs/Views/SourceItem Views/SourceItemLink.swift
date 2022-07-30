//
//  SourceItemLink.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct SourceItemLink<Item: SourceItem>: View {
    @Binding var selection: UUID?

    var item   : Item

    var body: some View {
        NavigationLink(tag: item.id, selection: $selection,
            destination: { SourceItemContent(item: item) },
            label: { SourceItemLabel(item: item) }
        )
    }
}

struct SourceItemLink_Previews: PreviewProvider {
    @State static var selection : UUID?
    static var state = SourceState(model: SimModel())
    static var sampleItem = state.deviceStyleItems()[0]

    static var previews: some View {
        SourceItemLink(selection: $selection, item: sampleItem)
            .preferredColorScheme(.dark)
        SourceItemLink(selection: $selection, item: sampleItem)
            .preferredColorScheme(.light)
    }
}
