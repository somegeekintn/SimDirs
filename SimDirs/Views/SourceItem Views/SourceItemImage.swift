//
//  SourceItemImage.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct SourceItemImage: View {
    var imageDesc       : SourceImageDesc
    var isLabelImage    = true
    var imageSize       : CGFloat?

    var body: some View {
        let size    = imageSize ?? (isLabelImage ? 20.0 : 128.0)

        switch imageDesc {
            case let .icon(nsImage):
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: size, maxHeight: size)
                    .cornerRadius(size / 5.0)
                    .shadow(radius: 4.0, x: 2.0, y: 2.0)
                    
            case let .symbol(systemName, color):
                if isLabelImage {
                    Image(systemName: systemName)
                        .foregroundColor(color)
                        .symbolRenderingMode(.hierarchical)
                }
                else {
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: size, maxHeight: size)
                        .shadow(radius: 4.0, x: 2.0, y: 2.0)
                }
        }
    }
}

struct SourceItemImage_Previews: PreviewProvider {
    static var state = SourceState(model: SimModel())
    static var sampleItems = state.deviceStyleItems()[0...1]

    static var previews: some View {
        ForEach(sampleItems) { item in
            SourceItemImage(imageDesc: item.imageDesc)
            SourceItemImage(imageDesc: item.imageDesc, isLabelImage: false)
        }
    }
}
