//
//  SimCtl.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import Foundation

struct SimCtl {
    func run(args: [String]) throws -> Data {
        let process = Process()
        let pipe    = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl"] + args
        process.standardOutput = pipe
        process.standardError = nil
        try process.run()
        
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
    
    func run(args: [String]) throws -> String {
        return String(data: try run(args: args), encoding: .utf8) ?? ""
    }

    func readAllDeviceTypes() throws -> [SimDeviceType] {
        let json    : Data = try run(args: ["list", "-j", "devicetypes"])
        
        return try JSONDecoder().decode([String : [SimDeviceType]].self, from: json)["devicetypes"] ?? []
    }
    
    func readAllRuntimes() throws -> [SimRuntime] {
        let json    : Data = try run(args: ["list", "-j", "runtimes"])
        
        return try JSONDecoder().decode([String : [SimRuntime]].self, from: json)["runtimes"] ?? []
    }
    
    func readAllRuntimeDevices() throws -> [String : [SimDevice]] {
        let json    : Data = try run(args: ["list", "-j", "devices"])
        
        return try JSONDecoder().decode([String : [String : [SimDevice]]].self, from: json)["devices"] ?? [:]
    }
}
