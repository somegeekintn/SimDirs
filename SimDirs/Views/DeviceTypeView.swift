//
//  DeviceTypeView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/25/22.
//

import SwiftUI

struct DeviceTypeView: View {
    var deviceType  : SimDeviceType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
//            Text(deviceType.name)
//                .font(.title)
//                .padding(.bottom, 5.0)
            Group {
                Text("Product Family: \(deviceType.productFamily.title)")
                Text("Model ID: \(deviceType.modelIdentifier)")
                Text("Identifier: \(deviceType.identifier)")
                Text("Min Runtime: \(deviceType.minRuntimeVersionString)")
                Text("Max Runtime: \(UInt32.max == deviceType.maxRuntimeVersion ? "-" : deviceType.maxRuntimeVersionString)")
                Text("Bundle Path: \(deviceType.bundlePath)")
            }
            .font(.subheadline)
        }
//        .background(Color.red)
    }
}

struct DeviceTypeView_Previews: PreviewProvider {
    static let model = PresentableModel().baseModel
    
    static var previews: some View {
        DeviceTypeView(deviceType: model.deviceTypes[26])
    }
}
