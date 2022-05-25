//
//  ContentView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

struct Item: Identifiable {
    var id: Int
    var name: String

    init(id: Int) {
        self.id = id
        self.name = "\(id)"
    }
}

struct ContentView: View {
    @EnvironmentObject var modelData    : PresentableModel
    @State private var toggleVal        = false
    
    let testItems = (0..<10).map({ Item(id: $0) })

    var body: some View {
        NavigationView {
            List {
                OutlineGroup(modelData.items, children: \.children) { item in
                    NavigationLink {
                        VStack {
                            HStack {
                                switch item.underlying {
                                    case let deviceType as SimDeviceType:
                                        DeviceTypeView(deviceType: deviceType)
                                        
                                    default:
                                        Text("\(item.title)")
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.all)
                        .navigationTitle(item.title)
                    } label: {
                        Label(item.title, systemImage: item.imageName)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PresentableModel())
    }
}
