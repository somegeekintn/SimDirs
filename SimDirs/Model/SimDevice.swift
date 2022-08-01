//
//  SimDevice.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import SwiftUI

class SimDevice: ObservableObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case availabilityError
        case dataPath
        case dataPathSize
        case deviceTypeIdentifier
        case isAvailable
        case logPath
        case name
        case state
        case udid
    }
    
    @Published var name                 : String
    @Published var state                : State
    @Published var isAvailable          : Bool
    @Published var availabilityError    : String?
    @Published var appearance           = Appearance.unknown
    @Published var contentSize          = ContentSize.unknown
    var isTransitioning                 : Bool { state == .booting || state == .shuttingDown }
    var isBooted                        : Bool {
        get { state.showBooted == true }
        set { bootDevice(newValue) }
    }

    let udid                    : String
    let dataPath                : String
    let dataPathSize            : Int
    let logPath                 : String
    let deviceTypeIdentifier    : String
    var deviceModel             : String?
    var apps                    = [SimApp]()
    var dataURL                 : URL { URL(fileURLWithPath: dataPath) }
    var logURL                  : URL { URL(fileURLWithPath: logPath) }
    var bundleContainerURL      : URL { dataURL.appendingPathComponent("Containers/Bundle/Application") }
    var dataContainerURL        : URL { dataURL.appendingPathComponent("Containers/Data/Application") }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        availabilityError = try values.decodeIfPresent(String.self, forKey: .availabilityError)
        dataPath = try values.decode(String.self, forKey: .dataPath)
        dataPathSize = try values.decode(Int.self, forKey: .dataPathSize)
        deviceTypeIdentifier = try values.decode(String.self, forKey: .deviceTypeIdentifier)
        isAvailable = try values.decode(Bool.self, forKey: .isAvailable)
        logPath = try values.decode(String.self, forKey: .logPath)
        name = try values.decode(String.self, forKey: .name)
        state = try values.decode(State.self, forKey: .state)
        udid = try values.decode(String.self, forKey: .udid)
    }
    
    func isDeviceOfType(_ deviceType: SimDeviceType) -> Bool {
        return deviceTypeIdentifier == deviceType.identifier
    }
    
    func completeSetup(with devTypes: [SimDeviceType]) {
        deviceModel = devTypes.first(where: { $0.identifier == deviceTypeIdentifier })?.name
        scanApplications()
    }
    
    func scanApplications() {
        let fileManager         = FileManager.default
        var sandboxPaths        = [String : URL]()
        
        if let dataDirs = try? fileManager.contentsOfDirectory(at: dataContainerURL, includingPropertiesForKeys: nil) {
            for dataDir in dataDirs {
                let metadataURL     = dataDir.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                guard let metadata	= PropertyListSerialization.propertyList(from: metadataURL) else { continue }
                guard let bundleID	= metadata["MCMMetadataIdentifier"] as? String else { continue }

                sandboxPaths[bundleID] = dataDir
            }
        }

        if let bundleDirs = try? fileManager.contentsOfDirectory(at: bundleContainerURL, includingPropertiesForKeys: nil) {
            apps.removeAll()
            for bundleDir in bundleDirs {
                guard let testDirs = try? fileManager.contentsOfDirectory(at: bundleDir, includingPropertiesForKeys: nil) else { continue }
                
                for testDir in testDirs {
                    if NSWorkspace.shared.isFilePackage(atPath: testDir.path) {
                        do {
                            apps.append(try SimApp(bundlePath: testDir, sandboxPaths: sandboxPaths))
                        }
                        catch {
                            print("Failed to instantiate SimApp at \(testDir.path)")
                        }
                    }
                }
            }
        }
    }
    
    func hasChanged(from other: SimDevice) -> Bool {
        return !(name == other.name && state == other.state && isAvailable == other.isAvailable && availabilityError == other.availabilityError)
    }

    @discardableResult func updateDevice(from other: SimDevice) -> Bool {
        guard hasChanged(from: other) else { return false }
        
        name = other.name
        state = other.state
        isAvailable = other.isAvailable
        availabilityError = other.availabilityError

        return true
    }
    
    func bootDevice(_ boot: Bool) {
        if boot && state == .shutdown || !boot && state == .booted {
            state = boot ? .booting : .shuttingDown
            Task {
                do {
                    try await SimCtl().bootDevice(self, boot: boot)
                } catch {
                    print("Failed to \(boot ? "boot" : "shutdown") device: \(error)")
                }
            }
        }
    }
    
    func discoverUI() {
        if appearance == .unknown {
            Task {
                let result = try await SimCtl().getDeviceAppearance(self)
                
                await MainActor.run { appearance = result }
            }
        }
        if contentSize == .unknown {
            Task {
                let result = try await SimCtl().getDeviceContentSize(self)
                
                await MainActor.run { contentSize = result }
            }
        }
    }
    
    func setAppearance(_ appearance: Appearance) {
        self.appearance = appearance     // optimistic
        
        do {
            try SimCtl().setDeviceAppearance(self, appearance: appearance)
        } catch {
            print("Failed to set device appeaarnce: \(error)")
        }
    }
    
    func setContenSize(_ contentSize: ContentSize) {
        self.contentSize = contentSize  // optimistic
        
        do {
            try SimCtl().setDeviceContentSize(self, contentSize: contentSize)
        } catch {
            print("Failed to set device content size: \(error)")
        }
    }
}

extension SimDevice {
    enum State: String, Decodable {
        case booting        = "Booting"
        case booted         = "Booted"
        case shuttingDown   = "Shutting Down"
        case shutdown       = "Shutdown"
        
        var showBooted      : Bool {
            switch self {
                case .booted, .booting: return true
                default:                return false
            }
        }
    }

    enum Appearance: String {
        case light          = "light"
        case dark           = "dark"
        case unsupported    = "unsupported"
        case unknown        = "unknown"
    }

    enum ContentSize: String {
        case XS             = "extra-small"
        case S              = "small"
        case M              = "medium"
        case L              = "large"
        case XL             = "extra-large"
        case XXL            = "extra-extra-large"
        case XXXL           = "extra-extra-extra-large"
        case A12Y_M         = "accessibility-medium"
        case A12Y_L         = "accessibility-large"
        case A12Y_XL        = "accessibility-extra-large"
        case A12Y_XXL       = "accessibility-extra-extra-large"
        case A12Y_XXXL      = "accessibility-extra-extra-extra-large"
        case unsupported    = "unsupported"
        case unknown        = "unknown"
        
        static var range    : ClosedRange<Double> { Double(ContentSize.XS.intValue)...Double(ContentSize.A12Y_XXXL.intValue) }

        var intValue        : Int {
            switch self {
                case .XS:           return 0
                case .S:            return 1
                case .M:            return 2
                case .L:            return 3
                case .XL:           return 4
                case .XXL:          return 5
                case .XXXL:         return 6
                case .A12Y_M:       return 7
                case .A12Y_L:       return 8
                case .A12Y_XL:      return 8
                case .A12Y_XXL:     return 10
                case .A12Y_XXXL:    return 11
                case .unsupported:  return 12
                case .unknown:      return 13
            }
        }

        init(intValue: Int) {
            switch intValue {
                case 0:     self = .XS
                case 1:     self = .S
                case 2:     self = .M
                case 3:     self = .L
                case 4:     self = .XL
                case 5:     self = .XXL
                case 6:     self = .XXXL
                case 7:     self = .A12Y_M
                case 8:     self = .A12Y_L
                case 9:     self = .A12Y_XL
                case 10:    self = .A12Y_XXL
                case 11:    self = .A12Y_XXXL
                case 12:    self = .unsupported
                default:    self = .unknown
            }
        }
    }
}

extension SimDevice: SourceItemData {
    var title       : String { return name }
    var headerTitle : String { "Device: \(title)" }
    var imageDesc   : SourceImageDesc { .symbol(systemName: "questionmark.circle", color: isAvailable ? .green : .red) }
}

extension Array where Element == SimDevice {
    func of(deviceType: SimDeviceType) -> Self {
        filter { $0.isDeviceOfType(deviceType) }
    }

    func completeSetup(with devTypes: [SimDeviceType]) {
        for device in self { device.completeSetup(with: devTypes) }
    }
}
