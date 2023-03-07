//
//  RuntimeContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct RuntimeContent: View {
    struct SupportedItem: Identifiable {
        let name    : String
        var id      : String { return name }
    }

    var runtime         : SimRuntime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            let items = runtime.supportedDeviceTypes.map { SupportedItem(name: $0.name) }
            
            Group {
                if !runtime.isAvailable {
                    ErrorView(
                        title: "\(runtime.name) is unavailable",
                        description: runtime.availabilityError ?? "Unknown Error")
                }

                ContentHeader("Paths")
                if !runtime.bundlePath.isEmpty {
                    PathRow(title: "Bundle Path", path: runtime.bundlePath)
                }
                
                ContentHeader("Supported devices\(runtime.isPlaceholder ? " (partial list)" : "")")
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

struct RuntimeContent_Previews: PreviewProvider {
    static var runtimes    = SimModel().runtimes
    
    static var previews: some View {
        RuntimeContent(runtime: runtimes[0])
    }
}
