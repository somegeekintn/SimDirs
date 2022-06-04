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
    static var model   = PresentableModel()
    
    static var previews: some View {
        SimItemContent(item: model.items[0].children![0])
    }
}
