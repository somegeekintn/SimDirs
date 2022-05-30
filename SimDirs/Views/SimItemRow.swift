//
//  SimItemRow.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/30/22.
//

import SwiftUI

struct SimItemRow: View {
    var item    : PresentationItem

    var body: some View {
        HStack {
            Image(systemName: item.imageName)
                .foregroundColor(item.imageColor)
                .symbolRenderingMode(.hierarchical)
            Text(item.title)
        }
    }
}

struct SimItemRow_Previews: PreviewProvider {
    static var model   = PresentableModel()
    
    static var previews: some View {
        SimItemRow(item: model.items[0])
    }
}
