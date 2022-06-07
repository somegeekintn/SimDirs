//
//  SimModel.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import Foundation

enum SimError: Error {
    case deviceParsingFailure
    case invalidApp
}

class SimModel: ObservableObject {
    var deviceTypes : [SimDeviceType]
    var runtimes    : [SimRuntime]
    
    init() {
        do {
            var json        : Data
            let decoder     = JSONDecoder()
            let runtimeDevs : [String : [SimDevice]]
            
            // - [SimDeviceType]
            json = try SimCtl.run(args: ["list", "-j", "devicetypes"])
            deviceTypes = try decoder.decode([String : [SimDeviceType]].self, from: json)["devicetypes"] ?? []

            // - [SimRuntime]
            json = try SimCtl.run(args: ["list", "-j", "runtimes"])
            runtimes = try decoder.decode([String : [SimRuntime]].self, from: json)["runtimes"] ?? []

            // - [SimDevice]
            json = try SimCtl.run(args: ["list", "-j", "devices"])
            runtimeDevs = try decoder.decode([String : [String : [SimDevice]]] .self, from: json)["devices"] ?? [:]
            
            for (runtimeID, devices) in runtimeDevs {
                do {
                    let runtimeIdx = try runtimes.indexOfMatchedOrCreated(identifier: runtimeID)
                    
                    runtimes[runtimeIdx].setDevices(devices, from: deviceTypes)
                }
                catch {
                    print("Warning: Unable to create placeholder runtime from \(runtimeID)")
                }
            }
            
            runtimes.sort()
        }
        catch {
            fatalError("Failed to initialize data model:\n\(error)")
        }
    }
}
