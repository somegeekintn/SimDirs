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
            Text(item.title)
        }
    }
}

struct SimItemRow_Previews: PreviewProvider {
    static var model   = PresentableModel()
    
    static var previews: some View {
        Group {
            SimItemRow(item: model.items[0])
        }
    }
}
