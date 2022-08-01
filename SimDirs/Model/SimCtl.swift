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
        return try String(data: run(args: args), encoding: .utf8) ?? ""
    }

    func runAsync(args: [String]) throws {
        Task(priority: nil, operation: { let _ : Data = try run(args: args) })
    }

    func runAsync(args: [String]) async throws -> Data {
        return try await Task(priority: nil, operation: { try run(args: args) }).value
    }
    
    func runAsync(args: [String]) async throws -> String {
        return try await Task(priority: nil, operation: { try String(data: run(args: args), encoding: .utf8) ?? "" }).value
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
    
    func readDevice(_ device: SimDevice) throws -> SimDevice? {
        let json    : Data = try run(args: ["list", "-j", "devices", device.udid])
        let decoded = try JSONDecoder().decode([String : [String : [SimDevice]]].self, from: json)["devices"] ?? [:]
        var result  : SimDevice? = nil
        
        for devices in decoded.values {
            if let match = devices.first(where: { $0.udid == device.udid }) {
                result = match
                break
            }
        }
        
        return result
    }
    
    func readAllDevices() throws -> [SimDevice] {
       return try readAllRuntimeDevices().flatMap { $1 }
    }
    
    func bootDevice(_ device: SimDevice, boot: Bool) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { let _ : Data = try run(args: [boot ? "boot" : "shutdown", device.udid]) }
            group.addTask { try await Task.sleep(nanoseconds: 1_000_000_000) }
            try await group.next()  // wait for timeout or run to complate
        }

        if let refreshedDev = try readDevice(device) {
            await MainActor.run { () -> Void in device.updateDevice(from: refreshedDev) }
        }
    }
    
    func getDeviceAppearance(_ device: SimDevice) async throws -> SimDevice.Appearance {
        let appearance : String = try await runAsync(args: ["ui", device.udid, "appearance"]).trimmingCharacters(in: .whitespacesAndNewlines)

        return SimDevice.Appearance(rawValue: appearance) ?? .unknown
    }
    
    func setDeviceAppearance(_ device: SimDevice, appearance: SimDevice.Appearance) throws {
        try runAsync(args: ["ui", device.udid, "appearance", appearance.rawValue])
    }
    
    func getDeviceContentSize(_ device: SimDevice) async throws -> SimDevice.ContentSize {
        let contentSize : String = try await runAsync(args: ["ui", device.udid, "content_size"]).trimmingCharacters(in: .whitespacesAndNewlines)

        return SimDevice.ContentSize(rawValue: contentSize) ?? .unknown
    }
    
    func setDeviceContentSize(_ device: SimDevice, contentSize: SimDevice.ContentSize) throws {
        try runAsync(args: ["ui", device.udid, "content_size", contentSize.rawValue])
    }
}
