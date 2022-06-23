//
//  DeviceHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimDevice {
    public var header : some View { DeviceHeader(device: self) }
}

struct DeviceHeader: View {
    var device         : SimDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Text("State: \(device.state.rawValue)")
            Text("UDID: \(device.udid)")
        }
        .font(.subheadline)
        .textSelection(.enabled)
    }
}

struct DeviceHeader_Previews: PreviewProvider {
    static var devices    = SimModel().devices
    
    static var previews: some View {
        DeviceHeader(device: devices[0])
        DeviceHeader(device: devices.randomElement() ?? devices[1])
    }
}
