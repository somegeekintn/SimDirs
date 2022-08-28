//
//  SimCtl.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import Foundation

struct SimCtl {
    func run(args: [String], run: Bool = true) throws -> Process {
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl"] + args
        process.standardError = nil
        if run {
            try process.run()
        }
        
        return process
    }
    
    func run(args: [String]) throws -> Data {
        let process : Process = try run(args: args, run: false)
        let pipe    = Pipe()
        
        process.standardOutput = pipe
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

    func getDeviceIncreaseContrast(_ device: SimDevice) async throws -> SimDevice.IncreaseContrast {
        let increaseContrast : String = try await runAsync(args: ["ui", device.udid, "increase_contrast"]).trimmingCharacters(in: .whitespacesAndNewlines)

        return SimDevice.IncreaseContrast(rawValue: increaseContrast) ?? .unknown
    }
    
    func setDeviceIncreaseContrast(_ device: SimDevice, increaseContrast: SimDevice.IncreaseContrast) throws {
        try runAsync(args: ["ui", device.udid, "increase_contrast", increaseContrast.rawValue])
    }
    
    func saveScreen(_ device: SimDevice, url: URL) throws {
        try runAsync(args: ["io", device.udid, "screenshot", url.path])
    }
    
    func saveVideo(_ device: SimDevice, url: URL) throws -> Process {
        return try run(args: ["io", device.udid, "recordVideo", "--force", url.path])
    }

    func getAppPID(_ app: SimApp) async throws -> Int? {
        guard let device = app.device else { return nil }
        let list    : String = try await runAsync(args: ["spawn", device.udid, "launchctl", "list"])
        let regex   = try NSRegularExpression(pattern: "(?<PID>[0-9]+).*\(app.bundleID)")
        let nsRange = NSRange(location: 0, length: (list as NSString).length)
        var pid     : Int? = nil
        
        if let match = regex.firstMatch(in: list, range: nsRange) {
            let range = match.range(withName: "PID")
            
            if range.location != NSNotFound {
                pid = Int((list as NSString).substring(with: range))
            }
        }

        return pid
    }
    
    func launch(_ app: SimApp) async throws -> Int? {
        guard let device = app.device else { return nil }
        let output : String = try await runAsync(args: ["launch", device.udid, app.bundleID])
        let regex   = try NSRegularExpression(pattern: ".*: (?<PID>[0-9]+)")
        let nsRange = NSRange(location: 0, length: (output as NSString).length)
        var pid     : Int? = nil
        
        if let match = regex.firstMatch(in: output, range: nsRange) {
            let range = match.range(withName: "PID")
            
            if range.location != NSNotFound {
                pid = Int((output as NSString).substring(with: range))
            }
        }

        return pid
    }
    
    func terminate(_ app: SimApp) throws {
        guard let device = app.device else { return }
        
        try runAsync(args: ["terminate", device.udid, app.bundleID])
    }
}
