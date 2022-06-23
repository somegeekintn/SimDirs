//
//  SourceItemContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

import SwiftUI

struct SourceItemContent<Item: SourceItem>: View {
    var item   : Item

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0.0) {
                // --- Header section ---
                VStack(alignment: .leading) {
                    Text(item.headerTitle)
                        .font(.system(size: 20))
                        .padding(.top, 12.0)
                        .padding(.bottom, 8.0)
                    item.header
                        .padding(.trailing, 136.0)
                }
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity, maxHeight: 144.0, alignment: .topLeading)
                Rectangle().frame(height: 1.0).foregroundColor(Color("HeaderEdge"))
                
                // --- Content section ---
                ScrollView {
                    HStack {
                        item.content
                            .padding(.top, 4.0)
                            .padding(.trailing)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .top])
                .background(.background)
            }
            .overlay(
                SourceItemImage(imageDesc: item.imageDesc, isLabelImage: false)
                    .padding([.top, .trailing], 24.0),
                alignment: .topTrailing
            )
            .padding(.top, -geometry.frame(in: .global).origin.y)
        }
        .navigationTitle(item.title)
    }
}

struct SourceItemContent_Previews: PreviewProvider {
    static var state = SourceState(model: SimModel())
    static var sampleItems = state.deviceStyleItems()[0...1]

    static var previews: some View {
        ForEach(sampleItems) { item in
            SourceItemContent(item: item)
                .preferredColorScheme(.dark)
            SourceItemContent(item: item)
                .preferredColorScheme(.light)
        }
    }
}
