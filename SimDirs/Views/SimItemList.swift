//
//  SimItemList.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/30/22.
//

import SwiftUI

struct SimItemList: View {
    @EnvironmentObject var modelData    : PresentableModel
    @State private var withApps         = false
    @State private var withRuntimes     = false

    var filteredItems                   : [PresentationItem] {
        var filter = PresentationFilter()
        
        if withApps { filter.update(with: .withApps) }
        if withRuntimes { filter.update(with: .runtimeInstalled) }
        
        return modelData.filteredItems(filter: filter)
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    OutlineGroup(filteredItems, children: \.children) { item in
                        NavigationLink {
                            SimItemContent(item: item)
                        } label: {
                            SimItemRow(item: item)
                        }
                    }
                    .padding(.leading, 2.0)
                }
                .frame(minWidth: 200)
                .toolbar {
                    ToolbarItem {
                        Menu {
                            Toggle(isOn: $withApps) {
                                Label("With Apps", systemImage: "app.fill")
                            }
                            Toggle(isOn: $withRuntimes) {
                                Label("Installed Runtimes", systemImage: "cpu.fill")
                            }
                        } label: {
                            Label("Filter", systemImage: "slider.horizontal.3")
                        }
                    }
                }
                Text("Search")
                    .padding(.bottom, 4.0)
            }
            Text("SimDirs")
        }
    }
}

struct SimItemList_Previews: PreviewProvider {
    static var previews: some View {
        SimItemList()
            .environmentObject(PresentableModel())
    }
}
