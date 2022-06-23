//
//  DeviceContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimDevice {
    public var content : some View { DeviceContent(device: self) }
}

struct DeviceContent: View {
    var device         : SimDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Group {
                if !device.isAvailable {
                    ErrorView(
                        title: "\(device.name) is unavailable",
                        description: device.availabilityError ?? "Unknown Error")
                }
                
                Text("PATHS")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                PathRow(title: "Data Path", path: device.dataPath)
                PathRow(title: "Log Path", path: device.logPath)
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
    }
}

struct DeviceContent_Previews: PreviewProvider {
    static var devices    = SimModel().devices
    
    static var previews: some View {
        DeviceContent(device: devices[0])
        DeviceContent(device: devices.randomElement() ?? devices[1])
    }
}
