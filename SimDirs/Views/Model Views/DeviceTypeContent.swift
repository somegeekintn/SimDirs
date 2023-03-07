//
//  DeviceTypeContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct DeviceTypeContent: View {
    var deviceType  : SimDeviceType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ContentHeader("Paths")
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
