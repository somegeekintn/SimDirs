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
    }

    @Published var name                 : String
    @Published var state                : State
    @Published var isAvailable          : Bool
    @Published var availabilityError    : String?

    let udid                    : String
    let dataPath                : String
    let dataPathSize            : Int
    let logPath                 : String
    let deviceTypeIdentifier    : String
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

    func updateDevice(from other: SimDevice) -> Bool {
        guard hasChanged(from: other) else { return false }
        
        name = other.name
        state = other.state
        isAvailable = other.isAvailable
        availabilityError = other.availabilityError

        return true
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
}
