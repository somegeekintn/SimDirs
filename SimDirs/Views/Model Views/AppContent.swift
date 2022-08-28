//
//  AppContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimApp {
    public var content : some View { AppContent(app: self) }

    var isLaunched  : Bool {
        get { state.isOn }
        set { toggleLaunchState() }
    }
}

extension SimApp.State: ToggleDescriptor {
    var titleKey    : LocalizedStringKey { isOn ? "Terminate" : "Launch" }
    var text        : String { isOn ? "Launched" : "Terminated" }
    var image       : Image { Image(systemName: "power.circle") }
}

struct AppContent: View {
    @ObservedObject var app     : SimApp

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ContentHeader("Paths")
            Group {
                PathRow(title: "Bundle Path", path: app.bundlePath)
                if let sandboxPath = app.sandboxPath {
                    PathRow(title: "Sandbox Path", path: sandboxPath)
                }
                else {
                    Text("Sandbox Path: <unknown>")
                }
            }
            .font(.subheadline)
            .lineLimit(1)

            ContentHeader("Actions")
            HStack(spacing: 16) {
                DescriptiveToggle(app.state, isOn: $app.isLaunched, subtitled: false)
                    .frame(width: 58)
            }
            .environment(\.isEnabled, app.device?.isBooted == true)
        }
        .onAppear {
            app.discoverState()
        }
    }
}

struct AppContent_Previews: PreviewProvider {
    static var apps     = SimModel().apps
    
    static var previews: some View {
        AppContent(app: apps[0])
        AppContent(app: apps.randomElement() ?? apps[1])
    }
}
