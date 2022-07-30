//
//  SourceItemGroup.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct SourceItemGroup<Item: SourceItem>: View {
    @StateObject var item               : Item
    @Binding var selection              : UUID?

    var body: some View {
        HStack(spacing: 0) {
            let button = Button(action: {
                let optionActive = NSApplication.shared.currentEvent?.modifierFlags.contains(.option) == true
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    item.toggleExpanded(deep: optionActive)
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .padding(.horizontal, 2.0)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(item.isExpanded ? 90.0 : 0.0))
            })
            .buttonStyle(.plain)
            
            if item.visibleChildren.count == 0 {
                button.hidden()
            }
            else {
                button
            }
            
            SourceItemLink(selection: $selection, item: item)
        }
        
        if item.isExpanded {
            ForEach(item.visibleChildren) { childItem in
                SourceItemGroup<Item.Child>(item: childItem, selection: $selection)
            }
            .padding(.leading, 12.0)
        }
    }
}

struct SourceItemGroup_Previews: PreviewProvider {
    @State static var selection : UUID?
    static var state = SourceState(model: SimModel())
    static var sampleItem = state.deviceStyleItems()[0]

    static var previews: some View {
        List {
            SourceItemGroup(item: sampleItem, selection: $selection)
            SourceItemGroup(item: sampleItem, selection: $selection)
            SourceItemGroup(item: sampleItem, selection: $selection)
        }
    }
}
