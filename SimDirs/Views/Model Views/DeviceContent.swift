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
    var contentSizeVal  : Double {
        get { Double(contentSize.intValue) }
        set { setContenSize(ContentSize(intValue: Int(newValue))) }
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
                HStack(spacing: 32) {
                    if device.appearance != .unsupported {
                        AppearancePicker(scheme: $device.scheme)
                    }
                    if device.contentSize != .unsupported {
                        VStack {
                            HStack {
                                Image(systemName: "textformat.size")
                                    .imageScale(.small)
                                Slider(value: $device.contentSizeVal, in: SimDevice.ContentSize.range, step: 1)
                                Image(systemName: "textformat.size")
                                    .imageScale(.large)
                            }
                            Text("Content Size")
                        }
                    }
                }
                .disabled(!device.isBooted)
            }
            .font(.subheadline)
            .textSelection(.enabled)
            .lineLimit(1)
        }
        .onAppear {
            device.discoverUI()
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
