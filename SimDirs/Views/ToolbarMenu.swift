//
//  ToolbarMenu.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/7/22.
//

import SwiftUI

struct ToolbarMenu: View {
    @Binding var state  : PresentationState

    var withApps        : Binding<Bool> {
        Binding(get: { state.filter.contains(.withApps) },
                set: { state.filter.booleanSet($0, options: .withApps) })
    }
    var withRuntimes    : Binding<Bool> {
        Binding(get: { state.filter.contains(.runtimeInstalled) },
                set: { state.filter.booleanSet($0, options: .runtimeInstalled) })
    }

    var body: some View {
        Menu {
            Picker("Organization", selection: $state.organization) {
                ForEach(PresentationState.Organization.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.inline)
            Toggle(isOn: withApps) { Label("With Apps", systemImage: "app.fill") }
            Toggle(isOn: withRuntimes) { Label("Installed Runtimes", systemImage:  "cpu.fill") }
        } label: {
            Label("Filter", systemImage: "slider.horizontal.3")
        }
    }
}

struct ToolbarMenu_Previews: PreviewProvider {
    @State static var state = PresentationState(filter: [])

    static var previews: some View {
        ToolbarMenu(state: $state)
    }
}

