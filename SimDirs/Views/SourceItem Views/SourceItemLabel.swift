//
//  SourceItemLabel.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct SourceItemLabel<Item: SourceItem>: View {
    var item   : Item

    var body: some View {
        Label(
            title: { Text(item.title) },
            icon: { SourceItemImage(imageDesc: item.imageDesc) }
        )
    }
}

struct SourceItemLabel_Previews: PreviewProvider {
    static var state = SourceState(model: SimModel())
    static var sampleItems = state.deviceStyleItems()[0...1]

    static var previews: some View {
        ForEach(sampleItems) { item in
            SourceItemLabel(item: item)
            SourceItemLabel(item: item)
        }
    }
}
