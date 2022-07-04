//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var state    : SourceState
    
    init(model: SimModel) {
        state = SourceState(model: model)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Divider()

                    switch state.base {
                        case .placeholder:
                            Text("Placeholder")

                        case let .device(_, item):
                            ForEach(item.visibleChildren) {
                                SourceItemGroup(selection: $state.selection, item: $0)
                            }
                            
                        case let .runtime(_, item):
                            ForEach(item.visibleChildren) {
                                SourceItemGroup(selection: $state.selection, item: $0)
                            }
                    }
                }
                .toolbar {
                    ToolbarItem { ToolbarMenu(state: state) }
                }
                .frame(minWidth: 200)
                
                Image("Icon-256")   // Initial View
            }
            .searchable(text: $state.filter.searchTerm, placement: .sidebar)
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
