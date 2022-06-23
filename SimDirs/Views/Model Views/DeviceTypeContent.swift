//
//  DeviceTypeContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

extension SimDeviceType {
    public var content : some View { DeviceTypeContent(deviceType: self) }
}

struct DeviceTypeContent: View {
    var deviceType  : SimDeviceType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            PathRow(title: "Bundle Path", path: deviceType.bundlePath)
        }
        .font(.subheadline)
        .lineLimit(1)
    }
}

struct DeviceTypeContent_Previews: PreviewProvider {
    static var deviceTypes    = SimModel().deviceTypes
    
    static var previews: some View {
        DeviceTypeContent(deviceType: deviceTypes[0])
    }
}
