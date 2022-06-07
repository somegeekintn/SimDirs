//
//  AppView.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/4/22.
//

import SwiftUI

extension SimApp {
    var contentView : AnyView? { return AnyView(AppView(app: self)) }
}

struct AppView: View {
    var app     : SimApp
    var icon    : Image { app.nsIcon.map({ Image(nsImage: $0) }) ??
                            Image(systemName: "questionmark.app.dashed")
                        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Group {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Display Name: \(app.displayName)")
                        Text("Bundle Name: \(app.bundleName)")
                        Text("Bundle ID: \(app.bundleID)")
                        Text("Version: \(app.version)")
                        Text("Minimum OS Version: \(app.minOSVersion)")
                    }
                    Spacer()
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 72.0, maxHeight: 72.0)
                        .cornerRadius(4.0)
                }
                Divider()
                    .padding([.top, .bottom], 4.0)
                PathRow(title: "Bundle Path", path: app.bundlePath)
                if let sandboxPath = app.sandboxPath {
                    PathRow(title: "Sandbox Path", path: sandboxPath)
                }
                else {
                    Text("Sandbox Path: <unknown>")
                }
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let apps    = PresentationState.testItemsOf(type: SimApp.self)
        
        if apps.isEmpty {
            Text("No SimApp present in model data")
        }
        else {
            ForEach(apps[0...2]) {
                AppView(app: $0)
            }
        }
    }
}
