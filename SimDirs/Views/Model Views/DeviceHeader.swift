//
//  DeviceHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

struct DeviceHeader: View {
    @ObservedObject var device  : SimDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            HStack(spacing: 8.0) {
                Toggle("Booted", isOn: $device.isBooted)
                    .toggleStyle(.switch)
                    .disabled(device.isTransitioning)

                if device.isTransitioning {
                    ProgressView()
                        .controlSize(.small)
                    Text(device.state.rawValue)
                }
            }
            Text("Model: \(device.deviceModel ?? "- unknown - ")")
            Text("Identifier: \(device.udid)")
        }
        .font(.subheadline)
        .textSelection(.enabled)
    }
}

struct DeviceHeader_Previews: PreviewProvider {
    static var devices    = SimModel().devices
    
    static var previews: some View {
        if !devices.isEmpty {
            DeviceHeader(device: devices[0])
            DeviceHeader(device: devices.randomElement() ?? devices[1])
        }
        else {
            Text("No devices")
        }
    }
}
