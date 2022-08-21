//
//  DeviceContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI
import UniformTypeIdentifiers

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
    enum SaveType {
        case image
        case video
        
        var allowedContentTypes : [UTType] {
            switch self {
                case .image:    return [.png]
                case .video:    return [.mpeg4Movie]
            }
        }
        
        var title : String {
            switch self {
                case .image:    return "Save Screen"
                case .video:    return "Save Recording"
            }
        }
    }
    
    @ObservedObject var device  : SimDevice
    @State var isBooted         : Bool
    
    var fileDateFormatter       : DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd'_'HH.mm.ss"
        
        return formatter
    }
    
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
            
            ContentHeader("Actions")
            HStack(spacing: 16) {
                Button(action: { saveScreen(.image) }) {
                    Text("Save Screen")
                        .fontWeight(.semibold)
                        .font(.system(size: 11))
                }
                .buttonStyle(.systemIcon("camera.on.rectangle"))
                
                Button(action: { device.isRecording ? device.endRecording() : saveScreen(.video) }) {
                    Text(device.isRecording ? "End Recording" : "Record Screen")
                        .fontWeight(.semibold)
                        .font(.system(size: 11))
                }
                .buttonStyle(.systemIcon("record.circle", active: device.isRecording))
            }

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
    
    func saveScreen(_ type: SaveType = .image) {
        let savePanel = NSSavePanel()
        
        savePanel.allowedContentTypes = type.allowedContentTypes
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = type.title
        savePanel.message = "Select destination"
        savePanel.nameFieldLabel = "Filename:"
        savePanel.nameFieldStringValue = "\(device.name) - \(fileDateFormatter.string(from: Date()))"

        if savePanel.runModal() == .OK {
            if let url = savePanel.url {
                switch type {
                    case .image: device.saveScreen(url)
                    case .video: device.saveVideo(url)
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
