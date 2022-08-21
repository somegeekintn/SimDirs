//
//  ContentHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 7/31/22.
//

import SwiftUI

struct ContentHeader: View {
    let title   : String
    
    init(_ title: String) {
        self.title = title.uppercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(Color("ContentHeader"))
                .padding(.top)
            Divider()
        }
        .padding(.bottom, 4)
    }
}

struct ContentHeader_Previews: PreviewProvider {
    static var previews: some View {
        ContentHeader("Content Header")
            .preferredColorScheme(.light)
        ContentHeader("Content Header")
            .preferredColorScheme(.dark)
    }
}
