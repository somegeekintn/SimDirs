//
//  SimItemList.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/30/22.
//

import SwiftUI

struct SimItemList: View {
    @EnvironmentObject var modelData    : PresentableModel
    @State private var toggleVal        = false

    var body: some View {
        NavigationView {
            List {
                OutlineGroup(modelData.items, children: \.children) { item in
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
//                        Picker("Category", selection: $filter) {
//                            ForEach(FilterCategory.allCases) { category in
//                                Text(category.rawValue).tag(category)
//                            }
//                        }
//                        .pickerStyle(.inline)
                        Toggle(isOn: $toggleVal) {
                            Label("Toggle", systemImage: "star.fill")
                        }
                    } label: {
                        Label("Filter", systemImage: "slider.horizontal.3")
                    }
                }
            }
            Text("SimDirs")    // If this isn't here things looks weird
        }
    }
}

struct SimItemList_Previews: PreviewProvider {
    static var previews: some View {
        SimItemList()
            .environmentObject(PresentableModel())
    }
}
