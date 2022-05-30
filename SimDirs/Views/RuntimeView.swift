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

struct UniqueItem: Identifiable {
    let name    : String
    var id      : String { return name }
}

struct RuntimeView: View {
    var runtime  : SimRuntime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            let items = runtime.supportedDeviceTypes.map({ UniqueItem(name: $0.name) })

            Group {
                if !runtime.buildversion.isEmpty {
                    Text("Build Version: \(runtime.buildversion)")
                }
                
                if !runtime.bundlePath.isEmpty {
                    HStack {
                        Text("Bundle Path: \(runtime.bundlePath)")
                        RuntimeActionGroup(runtime: runtime)
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

struct RuntimeActionGroup: View {
    var runtime  : SimRuntime

    var body: some View {
        // ControlGroup almost but not quite what we want
        HStack {
            Button(action: { print("Go!") }) {
                Image(systemName: "doc.on.doc")
            }
            Divider()
                .frame(height: 16.0)
            Button(action: { print("Copy") }) {
                Image(systemName: "arrow.right.circle.fill")
            }
        }
        .buttonStyle(.borderless)
        .padding(.vertical, 4.0)
        .padding(.horizontal, 8.0)
        .background(.black.opacity(0.4))
        .font(.headline)
        .cornerRadius(6.0)
    }
}

struct RuntimeActionGroup_Previews: PreviewProvider {
    static let model = SimModel()
    
    static var previews: some View {
        RuntimeActionGroup(runtime: model.runtimes[0])
    }
}

