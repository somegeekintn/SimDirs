//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model   : SimModel
    @State private var state    = PresentationState(filter: [])
    
    var rootItems   : [PresentationItem] { state.presentationItems(from: model) }

    var body: some View {
        NavigationView {
            List {
                ForEach(rootItems) { item in
                    SimItemGroup(item: item, state: $state)
                }
                .padding(.leading, 2.0)
            }
            .frame(minWidth: 200)
            .toolbar {
                ToolbarItem { ToolbarMenu(state: $state) }
            }
            Text("SimDirs")
        }
        .searchable(text: $state.searchTerm, placement: .sidebar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var simModel = SimModel()

    static var previews: some View {
        ContentView(model: simModel)
    }
}
