//
//  NodeLabel.swift
//  NodeItems
//
//  Created by Casey Fleser on 3/3/23.
//

import SwiftUI

struct NodeLabel<T: Node>: View {
    @ObservedObject var node   : FilteredNode<T>
    
    init(_ node: FilteredNode<T>) {
        self.node = node
    }
    
    var body: some View {
        HStack(spacing: 0) {
            let button =
                Button(
                    action: {
                        let optionActive = NSApplication.shared.currentEvent?.modifierFlags.contains(.option) == true
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            node.toggleExpanded(deep: optionActive)
                        }
                    },
                    label: {
                        Image(systemName: "chevron.right")
                            .padding(.horizontal, 4.0)
                            .contentShape(Rectangle())
                            .rotationEffect(.degrees(node.isExpanded ? 90.0 : 0.0))
                    }
                )
                .buttonStyle(.plain)
            
            if node.items != nil { button }
            else { button.hidden() }
            
            NavigationLink(
                destination: { NodeView(node) },
                label: {
                    Label(
                        title: { Text(node.title) },
                        icon: { node.icon(forHeader: false) }
                    )
                }
            )
        }
    }
}

struct NodeLabel_Previews: PreviewProvider {
    @StateObject static var previewItem = FilteredNode(SimPlatform.iOS)
    
    static var previews: some View {
        VStack {
            NodeLabel(previewItem)
        }
    }
}
