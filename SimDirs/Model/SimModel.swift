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
    var deviceTypes         : [SimDeviceType]
    @Published var runtimes : [SimRuntime]
    let timer               = DispatchSource.makeTimerSource()
    let updateInterval      = 1.0
    
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
            beginMonitor()
        }
        catch {
            fatalError("Failed to initialize data model:\n\(error)")
        }
    }
    
    func beginMonitor() {
        timer.setEventHandler {
            guard let runtimeDevs : [String : [SimDevice]] = try? SimCtl().readAllRuntimeDevices() else { return }

            // Device updating
            for (runtimeID, newDevices) in runtimeDevs {
                guard let runtime       = self.runtimes.first(where: { $0.identifier == runtimeID }) else { continue }
                let newDevIDs           = newDevices.map { $0.udid }
                let curDevIDs           = runtime.devices.map { $0.udid }
                let updates             = runtime.updatedDevices(from: newDevices)
                let deleteIDs           = curDevIDs.filter { !newDevIDs.contains($0) }
                let inserts             = newDevices.filter { !curDevIDs.contains($0.udid) }
                let changes             : (upd: Bool, del: Bool, ins: Bool) = (!updates.isEmpty, !deleteIDs.isEmpty, !inserts.isEmpty)

                if changes != (false, false, false) {
                    DispatchQueue.main.async {
                        guard let runtimeIdx    = self.runtimes.firstIndex(of: runtime) else { return }
                        
                        if changes.upd {
                            self.runtimes[runtimeIdx].applyDeviceUpdates(updates)
                        }
                        if changes.del {
                            self.runtimes[runtimeIdx].devices.removeAll(where: { deleteIDs.contains($0.udid) })
                        }
                        if changes.ins {
                            self.runtimes[runtimeIdx].devices.append(contentsOf: inserts)
                        }
                    }
                }
            }
        }
        timer.schedule(deadline: DispatchTime.now(), repeating: updateInterval)
        timer.resume()
    }
}
