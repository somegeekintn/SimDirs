//
//  NodeView.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/6/23.
//

import SwiftUI

struct NodeView<Item: Node>: View {
    var node   : Item

    init(_ node: Item) {
        self.node = node
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0.0) {
                // --- Header section ---
                VStack(alignment: .leading) {
                    Text(node.headerTitle)
                        .font(.system(size: 20))
                        .padding(.top, 12.0)
                        .padding(.bottom, 8.0)
                    node.header
                        .padding(.trailing, 136.0)
                }
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity, maxHeight: 144.0, alignment: .topLeading)
                Rectangle().frame(height: 1.0).foregroundColor(Color("HeaderEdge"))
                
                // --- Content section ---
                ScrollView {
                    HStack {
                        node.content
                            .padding(.top, 4.0)
                            .padding(.trailing)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .top])
                .background(.background)
            }
            .overlay(alignment: .topTrailing) {
                node.icon(forHeader: true)
                    .padding([.top, .trailing], 24.0)
            }
            .padding(.top, -geometry.frame(in: .global).origin.y)
        }
        .navigationTitle(node.title)
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView(SimPlatform.iOS)
    }
}
