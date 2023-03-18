//
//  SimModel.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/24/22.
//

import Foundation
import Combine

enum SimError: Error {
    case deviceParsingFailure
    case invalidApp
}

class SimModel {
    struct Update {
        let runtime     : SimRuntime
        var additions   : [SimDevice]
        var removals    : [SimDevice]
    }

    var deviceTypes         : [SimDeviceType]
    var runtimes            : [SimRuntime]
    var monitor             : Cancellable?
    let updateInterval      = 2.0
 
    var devices             : [SimDevice] { runtimes.flatMap { $0.devices } }
    var apps                : [SimApp] { devices.flatMap { $0.apps } }

    var deviceUpdates       = PassthroughSubject<SimModel.Update, Never>()
    
    init() {
        let simctl = SimCtl()
        
        do {
            let runtimeDevs : [String : [SimDevice]]

            deviceTypes = try simctl.readAllDeviceTypes()
            runtimes = try simctl.readAllRuntimes()
            runtimeDevs = try simctl.readAllRuntimeDevices()
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
            devices.completeSetup(with: deviceTypes)
            
            if !ProcessInfo.processInfo.isPreviewing {
                beginMonitor()
            }
        }
        catch {
            fatalError("Failed to initialize data model:\n\(error)")
        }
    }
    
    func beginMonitor() {
        monitor = Timer.publish(every: updateInterval, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.global(qos: .background))
            .flatMap { _ in
                Just((try? SimCtl().readAllRuntimeDevices()) ?? [String : [SimDevice]]())
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] runtimeDevs in
                guard let this = self else { return }
                
                for (runtimeID, curDevices) in runtimeDevs {
                    guard let runtime   = this.runtimes.first(where: { $0.identifier == runtimeID }) else { print("missing runtime: \(runtimeID)"); continue }
                    
                    if let changes = runtime.reconcileDevices(curDevices, forTypes: this.deviceTypes) {
                        this.deviceUpdates.send(changes)
                    }

                    for srcDevice in curDevices {
                        guard let dstDevice = runtime.devices.first(where: { $0.udid == srcDevice.udid }) else { print("missing device: \(srcDevice.udid)"); continue }
                        
                        if dstDevice.updateDevice(from: srcDevice) {
                            print("\(dstDevice.udid) updated: \(dstDevice.state)")
                        }
                    }
                }
            }
    }
}
