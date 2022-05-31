//
//  RuntimeView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/30/22.
//

import SwiftUI

extension SimRuntime {
    var contentView : AnyView? { return AnyView(RuntimeView(runtime: self)) }
}

struct RuntimeView: View {
    struct SupportedItem: Identifiable {
        let name    : String
        var id      : String { return name }
    }

    @Environment(\.scenePhase) private var scenePhase
    
    var runtime         : SimRuntime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            let items = runtime.supportedDeviceTypes.map({ SupportedItem(name: $0.name) })

            Group {
                if !runtime.buildversion.isEmpty {
                    Text("Build Version: \(runtime.buildversion)")
                }
                
                if !runtime.bundlePath.isEmpty {
                    HStack {
                        Text("Bundle Path: \(runtime.bundlePath)")
                        PathActions(path: runtime.bundlePath)
                    }
                }
                
                Text(runtime.isAvailable ? "Available" : "Unavailable")
                    .foregroundColor(runtime.isAvailable ? .green : .red)
                if !runtime.isAvailable {
                    let errText = runtime.availabilityError ?? "Unknown Error"
                    
                    Text(errText)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                
                Divider()
                    .padding(.vertical, 4.0)
                Text("Supports\(runtime.isPlaceholder ? " (partial list)" : "")")
                ForEach(items) { item in
                    Text("• \(item.name)")
                }
                .padding(.leading)
            }
            .font(.subheadline)
            .textSelection(.enabled)
        }
    }
}

struct RuntimeView_Previews: PreviewProvider {
    static let model = SimModel()
    
    static var previews: some View {
        RuntimeView(runtime: model.runtimes[0])
    }
}
