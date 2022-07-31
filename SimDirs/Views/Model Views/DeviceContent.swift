//
//  DeviceContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimDevice {
    public var content  : some View { DeviceContent(device: self) }
    var scheme          : ColorScheme? {
        get {
            switch appearance {
                case .light:    return .light
                case .dark:     return .dark
                default:        return nil
            }
        }
        set {
            switch newValue {
                case .light:    setAppearance(.light)
                case .dark:     setAppearance(.dark)
                default:        break
            }
        }
    }
}

struct DeviceContent: View {
    @ObservedObject var device  : SimDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Group {
                if !device.isAvailable {
                    ErrorView(
                        title: "\(device.name) is unavailable",
                        description: device.availabilityError ?? "Unknown Error")
                }
                
                ContentHeader("Paths")
                PathRow(title: "Data Path", path: device.dataPath)
                PathRow(title: "Log Path", path: device.logPath)
                
                ContentHeader("UI")
                if device.appearance != .unsupported {
                    AppearancePicker(scheme: $device.scheme)
                        .disabled(!device.isBooted)
                }
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
        .onAppear {
            device.discoverAppearance()
        }
    }
}

struct DeviceContent_Previews: PreviewProvider {
    static var devices    = SimModel().devices
    
    static var previews: some View {
        if !devices.isEmpty {
            DeviceContent(device: devices[0])
                .preferredColorScheme(.light)
            DeviceContent(device: devices.randomElement() ?? devices[0])
                .preferredColorScheme(.dark)
        }
        else {
            Text("No devices")
        }
    }
}
