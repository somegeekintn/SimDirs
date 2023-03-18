//
//  ToolbarMenu.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import SwiftUI

struct ToolbarMenu: View {
    @Binding var style          : ContentView.Style
    @Binding var filter         : SourceFilter

    var body: some View {
        Menu {
            Picker("Style", selection: $style) {
                ForEach(ContentView.Style.allCases) { style in
                    if style.visible {
                        Text(style.title).tag(style)
                    }
                }
            }
            .pickerStyle(.inline)
            Toggle(isOn: $filter.filterApps) { Label("With Apps", systemImage: "app.fill") }
            Toggle(isOn: $filter.filterRuntimes) { Label("Installed Runtimes", systemImage:  "cpu.fill") }
        } label: {
            Label("Filter", systemImage: "slider.horizontal.3")
        }
    }
}

struct ToolbarMenu_Previews: PreviewProvider {
    @State static var style     = ContentView.Style.byDevice
    @State static var filter    = SourceFilter.restore()

    static var previews: some View {
        ToolbarMenu(style: $style, filter: $filter)
    }
}
