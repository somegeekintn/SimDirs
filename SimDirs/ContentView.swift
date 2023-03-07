//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var state   : SourceState
    @State var filter           = SourceFilter.restore()
    
    init(model: SimModel) {
        state = SourceState(model: model)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                FilteredNodeView(filter: $filter) { state.items }
                    .id(state.style)
                    .toolbar { ToolbarItem { ToolbarMenu(state: state, filter: $filter) } }
                    .frame(minWidth: 200)
                
                Image("Icon-256")   // Initial View
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var model = SimModel()

    static var previews: some View {
        ContentView(model: model)
            .preferredColorScheme(.dark)
        ContentView(model: model)
            .preferredColorScheme(.light)
    }
}
