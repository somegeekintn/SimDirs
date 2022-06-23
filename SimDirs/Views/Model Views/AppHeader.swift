//
//  AppHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimApp {
    public var header : some View { AppHeader(app: self) }
}

struct AppHeader: View {
    var app     : SimApp

    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Text("Display Name: \(app.displayName)")
            Text("Bundle Name: \(app.bundleName)")
            Text("Bundle ID: \(app.bundleID)")
            Text("Version: \(app.version)")
            Text("Minimum OS Version: \(app.minOSVersion)")
        }
        .font(.subheadline)
    }
}

struct AppHeader_Previews: PreviewProvider {
    static var apps     = SimModel().apps
    
    static var previews: some View {
        AppHeader(app: apps[0])
        AppHeader(app: apps.randomElement() ?? apps[1])
    }
}
