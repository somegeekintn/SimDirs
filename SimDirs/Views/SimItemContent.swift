//
//  SimItemContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/30/22.
//

import SwiftUI

struct SimItemContent: View {
    var item    : PresentationItem

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    item.contentView
                    Spacer()
                }
                Spacer()
            }
            .padding(.all)
            .navigationTitle(item.navTitle)
        }
    }
}

struct SimItemContent_Previews: PreviewProvider {
    static var previews: some View {
        let testItem    = PresentationState().presentationItems(from: SimModel())[0]

        SimItemContent(item: testItem.children![0])
    }
}
