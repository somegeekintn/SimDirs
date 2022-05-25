//
//  SimCtl.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import Foundation

class SimCtl {
    static func run(args: [String]) throws -> Data {
        let process = Process()
        let pipe    = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl"] + args
        process.standardOutput = pipe
        try process.run()
        
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
        
    static func run(args: [String]) throws -> String {
        return String(data: try run(args: args), encoding: .utf8) ?? ""
    }

    static func dumpRuntimes() {
        print("dumpRuntimes")
        
        do {
            let json : String = try run(args: ["list", "-j", "runtimes"])

            print("json: \(json)")
        }
        catch {
            print(error)
        }
    }
    
    static func dumpDevices() {
        print("dumpDevices")
        
        do {
            let json : String = try run(args: ["list", "-j", "devices"])

            print("json: \(json)")
        }
        catch {
            print(error)
        }
    }
}
