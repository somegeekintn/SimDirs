//
//  SimDevice.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import SwiftUI

struct SimDevice: Decodable {
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

    let name                    : String
    let udid                    : String
    let state                   : String
    let dataPath                : String
    let dataPathSize            : Int
    let logPath                 : String
    let isAvailable             : Bool
    let deviceTypeIdentifier    : String
    let availabilityError       : String?
    var apps                    = [SimApp]()

    var dataURL                 : URL { URL(fileURLWithPath: dataPath) }
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
}

extension SimDevice: PresentableItem, Identifiable {
    var title       : String { return name }
    var id          : String { return udid }

    var imageName   : String { return "shippingbox" }
    var imageColor  : Color? { return isAvailable ? .green : .red }
}

