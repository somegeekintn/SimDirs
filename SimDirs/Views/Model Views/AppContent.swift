//
//  AppContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimApp {
    public var content : some View { AppContent(app: self) }
}

struct AppContent: View {
    var app     : SimApp

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ContentHeader("Paths")

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
    }
}

struct AppContent_Previews: PreviewProvider {
    static var apps     = SimModel().apps
    
    static var previews: some View {
        AppContent(app: apps[0])
        AppContent(app: apps.randomElement() ?? apps[1])
    }
}
