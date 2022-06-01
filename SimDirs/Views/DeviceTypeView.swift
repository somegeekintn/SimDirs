//
//  DeviceTypeView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/25/22.
//

import SwiftUI

extension SimDeviceType {
    var contentView : AnyView? { return AnyView(DeviceTypeView(deviceType: self)) }
}

struct DeviceTypeView: View {
    var deviceType  : SimDeviceType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Group {
                Text("Product Family: \(deviceType.productFamily.title)")
                Text("Model ID: \(deviceType.modelIdentifier)")
                Text("Min Runtime: \(deviceType.minRuntimeVersionString)")
                Text("Max Runtime: \(UInt32.max == deviceType.maxRuntimeVersion ? "-" : deviceType.maxRuntimeVersionString)")
                Text("Identifier: \(deviceType.identifier)")
                PathRow(title: "Bundle Path", path: deviceType.bundlePath)
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
    }
}

struct DeviceTypeView_Previews: PreviewProvider {
    static let model = SimModel()
    
    static var previews: some View {
        DeviceTypeView(deviceType: model.deviceTypes[0])
    }
}
