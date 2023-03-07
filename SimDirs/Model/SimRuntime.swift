//
//  SimRuntime.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import SwiftUI

class SimRuntime: ObservableObject, Comparable, Decodable {
    enum CodingKeys: String, CodingKey {
        case availabilityError
        case bundlePath
        case buildversion
        case identifier
        case isAvailable
        case isInternal
        case name
        case platform
        case runtimeRoot
        case supportedDeviceTypes
        case version
    }

    struct DeviceType: Decodable {
        let name                    : String
        let bundlePath              : String
        let identifier              : String
        let productFamily           : SimProductFamily
        
        init(canonical: SimDeviceType) {
            name = canonical.name
            bundlePath = canonical.bundlePath
            identifier = canonical.identifier
            productFamily = canonical.productFamily
        }
    }
    
    @Published var devices      = [SimDevice]()

    let name                    : String
    let version                 : String
    let identifier              : String
    let platform                : SimPlatform

    let bundlePath              : String
    let buildversion            : String
    let runtimeRoot             : String
    let isInternal              : Bool
    let isAvailable             : Bool
    var supportedDeviceTypes    : [DeviceType]
    let availabilityError       : String?
    
    var isPlaceholder           = false
    
    static func < (lhs: SimRuntime, rhs: SimRuntime) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: SimRuntime, rhs: SimRuntime) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(platformID: String) throws {
        guard let lastComponent = platformID.split(separator: ".").last else { throw SimError.deviceParsingFailure }
        let vComps              = lastComponent.split(separator: "-")
            
        if vComps.count == 3 {
            guard let compPlatform = SimPlatform(rawValue: String(vComps[0])) else { throw SimError.deviceParsingFailure }
            guard let major = Int(vComps[1]) else { throw SimError.deviceParsingFailure }
            guard let minor = Int(vComps[2]) else { throw SimError.deviceParsingFailure }

            platform = compPlatform
            version = "\(major).\(minor)"
            name = "\(platform) \(version)"
            identifier = platformID

            bundlePath = ""
            buildversion = ""
            runtimeRoot = ""
            isInternal = false
            isAvailable = false
            supportedDeviceTypes = []
            availabilityError = "Missing runtime"
            isPlaceholder = true
        }
        else {
            throw SimError.deviceParsingFailure
        }
    }
    
    func supports(deviceType: SimDeviceType) -> Bool {
        return supportedDeviceTypes.contains { $0.identifier == deviceType.identifier }
    }
    
    func supports(platform: SimPlatform) -> Bool {
        return self.platform == platform
    }
    
    func setDevices(_ devices: [SimDevice], from devTypes: [SimDeviceType]) {
        self.devices = devices

        // If this runtime is a placeholder it will be missing supported device types
        // create device type stubs based on the devices being added using supplied
        // fully described device types
        
        if isPlaceholder {
            let devTypeIDs = Set(devices.map({ $0.deviceTypeIdentifier }))
            
            self.supportedDeviceTypes = devTypeIDs.compactMap { devTypeID in
                devTypes.first(where: { $0.identifier == devTypeID }).map({ SimRuntime.DeviceType(canonical: $0) })
            }
        }
    }
}

extension Array where Element == SimRuntime {
    mutating func indexOfMatchedOrCreated(identifier: String) throws -> Index {
        return try firstIndex { $0.identifier == identifier } ?? {
            try self.append(SimRuntime(platformID: identifier))
            
            return self.endIndex - 1
        }()
    }
    
    func supporting(deviceType: SimDeviceType) -> Self {
        filter { $0.supports(deviceType: deviceType) }
    }
    
    func supporting(platform: SimPlatform) -> Self {
        filter { $0.supports(platform: platform) }
    }
}
