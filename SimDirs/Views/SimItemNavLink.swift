//
//  SimItemNavLink.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import SwiftUI

struct SimItemNavLink: View {
    let item        : PresentationItem

    var body: some View {
        NavigationLink {
            SimItemContent(item: item) } label: {
            SimItemRow(item: item)
        }
    }
}

struct SimItemNavLink_Previews: PreviewProvider {
    static var previews: some View {
        let testItem    = PresentationState().presentationItems(from: SimModel())[0]
        
        SimItemNavLink(item: testItem)
    }
}
