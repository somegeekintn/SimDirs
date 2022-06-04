//
//  DeviceView.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/1/22.
//

import SwiftUI

extension SimDevice {
    var contentView : AnyView? { return AnyView(DeviceView(device: self)) }
}

struct DeviceView: View {
    var device  : SimDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Group {
                Text(device.isAvailable ? "Available" : "Unavailable")
                    .foregroundColor(device.isAvailable ? .green : .red)
                if !device.isAvailable {
                    let errText = device.availabilityError ?? "Unknown Error"
                    
                    Text(errText)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                Text("State: \(device.state)")
                Text("UDID: \(device.udid)")
                PathRow(title: "Data Path", path: device.dataPath)
                PathRow(title: "Log Path", path: device.logPath)
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
    }
}

struct DeviceView_Previews: PreviewProvider {
    static let devices  = PresentableModel().itemsOf(type: SimDevice.self)
    
    static var previews: some View {
        if devices.isEmpty {
            Text("No SimDevice present in model data")
        }
        else {
            if let available = devices.first(where: { $0.isAvailable }) {
                DeviceView(device: available)
            }
            if let unavailable = devices.first(where: { !$0.isAvailable }) {
                DeviceView(device: unavailable)
            }
        }
    }
}
