//
//  PathRow.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/1/22.
//

import SwiftUI

struct PathRow: View {
    var title   : String
    var path    : String
    
    var body: some View {
        HStack {
            Text("\(title): \(path)")
                .truncationMode(/*@START_MENU_TOKEN@*/.middle/*@END_MENU_TOKEN@*/)
            Spacer()
            PathActions(path: path)
        }
    }
}

struct PathRow_Previews: PreviewProvider {
    static var previews: some View {
        PathRow(title: "Desktop Path", path: "~/Desktop")
    }
}
