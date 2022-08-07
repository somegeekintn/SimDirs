//
//  DeviceContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimDevice {
    public var content      : some View { DeviceContent(self) }
    
    var scheme              : ColorScheme? {
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
    
    var contentSizeVal      : Double {
        get { Double(contentSize.intValue) }
        set { setContenSize(ContentSize(intValue: Int(newValue))) }
    }
    
    var isIncreaseContrast  : Bool {
        get { increaseContrast.isOn }
        set { setIncreaseContrast(newValue ? .enabled : .disabled) }
    }
}

extension SimDevice.IncreaseContrast: ToggleDescriptor {
    var titleKey    : LocalizedStringKey { "Increase Contrast" }
    var text        : String { rawValue.capitalized }
    var image       : Image { Image(systemName: "circle.lefthalf.filled") }
}

struct DeviceContent: View {
    @ObservedObject var device  : SimDevice
    @State var isBooted         : Bool
    
    init(_ device: SimDevice) {
        self.device = device
        self.isBooted = device.isBooted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            ContentHeader("Paths")
            Group {
                if !device.isAvailable {
                    ErrorView(
                        title: "\(device.name) is unavailable",
                        description: device.availabilityError ?? "Unknown Error")
                }
                
                PathRow(title: "Data Path", path: device.dataPath)
                PathRow(title: "Log Path", path: device.logPath)
            }
            .font(.subheadline)
            .textSelection(.enabled)
            
            ContentHeader("UI")
            HStack(spacing: 16) {
                if device.appearance != .unsupported {
                    AppearancePicker(scheme: $device.scheme)
                }
                if device.appearance != .unsupported {
                    DescriptiveToggle(device.increaseContrast, isOn: $device.isIncreaseContrast)
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
                    .opacity(isBooted ? 1.0 : 0.5)
                }
            }
        }
        .environment(\.isEnabled, isBooted)
        .onAppear {
            device.discoverUI()
        }
        .onChange(of: device.state) { state in
            let trulyBooted = state == .booted
            
            if isBooted != trulyBooted {
                isBooted = trulyBooted
                
                if isBooted {
                    device.discoverUI()
                }
            }
        }
    }
}

struct DeviceContent_Previews: PreviewProvider {
    static var devices    = SimModel().devices
    
    static var previews: some View {
        if !devices.isEmpty {
            DeviceContent(devices[0])
                .preferredColorScheme(.light)
            DeviceContent(devices.randomElement() ?? devices[0])
                .preferredColorScheme(.dark)
        }
        else {
            Text("No devices")
        }
    }
}
