//
//  ErrorView.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

struct ErrorView: View {
    let title       : String
    let description : String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "xmark.octagon.fill")
                .symbolRenderingMode(.multicolor)
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 8.0)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            title: "Something bad",
            description: "Did you try turning it off and back on again?")
    }
}
