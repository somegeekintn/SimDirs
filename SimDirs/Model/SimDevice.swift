//
//  SimDevice.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import SwiftUI

struct SimDevice: Decodable, Equatable {
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

    var name                    : String
    let udid                    : String
    var state                   : State
    let dataPath                : String
    let dataPathSize            : Int
    let logPath                 : String
    var isAvailable             : Bool
    let deviceTypeIdentifier    : String
    var availabilityError       : String?
    var apps                    = [SimApp]()
    
    var dataURL                 : URL { URL(fileURLWithPath: dataPath) }
    var logURL                  : URL { URL(fileURLWithPath: logPath) }
    var bundleContainerURL      : URL { dataURL.appendingPathComponent("Containers/Bundle/Application") }
    var dataContainerURL        : URL { dataURL.appendingPathComponent("Containers/Data/Application") }
    var scannedDevice           : Self { var scanned = self; scanned.scanApplications(); return scanned }
    
    func isDeviceOfType(_ deviceType: SimDeviceType) -> Bool {
        return deviceTypeIdentifier == deviceType.identifier
    }
    
    mutating func scanApplications() {
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
    
    func hasChanged(from other: Self) -> Bool {
        return !(name == other.name && state == other.state && isAvailable == other.isAvailable && availabilityError == other.availabilityError)
    }

    func updatedDevice(from other: Self) -> Self? {
        guard hasChanged(from: other) else { return nil }
        var updated = self
        
        updated.name = other.name
        updated.state = other.state
        updated.isAvailable = other.isAvailable
        updated.availabilityError = other.availabilityError

        return updated
    }
    
    mutating func applyChanges(from other: Self) {
        name = other.name
        state = other.state
        isAvailable = other.isAvailable
        availabilityError = other.availabilityError
    }
}

extension SimDevice: PresentableItem, Identifiable {
    var title       : String { return name }
    var id          : String { return udid }

    var imageName   : String { return "shippingbox" }
    var imageColor  : Color? { return isAvailable ? .green : .red }
}

