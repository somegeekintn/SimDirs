//
//  ToolbarMenu.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import SwiftUI

struct ToolbarMenu: View {
    @ObservedObject var state   : SourceState
    @Binding var filter         : SourceFilter

    var body: some View {
        Menu {
            Picker("Style", selection: $state.style) {
                ForEach(SourceState.Style.allCases) { style in
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
    static var state            = SourceState(model: SimModel())
    @State static var filter    = SourceFilter.restore()

    static var previews: some View {
        ToolbarMenu(state: state, filter: $filter)
    }
}
