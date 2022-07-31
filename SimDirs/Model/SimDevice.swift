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

    @Published var name                 : String
    @Published var state                : State
    @Published var isAvailable          : Bool
    @Published var availabilityError    : String?
    @Published var appearance           = Appearance.unknown
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
    
    func discoverAppearance() {
        if appearance == .unknown {
            Task {
                let result = try await SimCtl().getDeviceAppearance(self)
                
                await MainActor.run { appearance = result }
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
