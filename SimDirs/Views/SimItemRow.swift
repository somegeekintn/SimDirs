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
        Label(title: { Text(item.title) }) {
            if let icon = item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(maxWidth: 20.0, maxHeight: 20.0)
                    .cornerRadius(4.0)
            }
            else {
                Image(systemName: item.imageName)
                    .foregroundColor(item.imageColor)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}

struct SimItemRow_Previews: PreviewProvider {
    static var previews: some View {
        let testItem    = PresentationState().presentationItems(from: SimModel())[0]

        SimItemRow(item: testItem)
    }
}
