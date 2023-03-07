//
//  DeviceTypeHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/20/22.
//

import SwiftUI

struct DeviceTypeHeader: View {
    var deviceType  : SimDeviceType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
                Text("Product Family: \(deviceType.productFamily.title)")
                Text("Model ID: \(deviceType.modelIdentifier)")
                Text("Min Runtime: \(deviceType.minRuntimeVersionString)")
                Text("Max Runtime: \(UInt32.max == deviceType.maxRuntimeVersion ? "-" : deviceType.maxRuntimeVersionString)")
                Text("Identifier: \(deviceType.identifier)")
        }
        .font(.subheadline)
        .textSelection(.enabled)
    }
}

struct DeviceTypeHeader_Previews: PreviewProvider {
    static var deviceTypes    = SimModel().deviceTypes
    
    static var previews: some View {
        DeviceTypeHeader(deviceType: deviceTypes[0])
    }
}
