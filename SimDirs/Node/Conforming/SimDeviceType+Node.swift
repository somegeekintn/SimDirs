//
//  SimDeviceType+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimDeviceType: Node {
    var title       : String { return name }
    var headerTitle : String { "Device Type: \(title)" }

    var header      : some View { DeviceTypeHeader(deviceType: self) }
    var content     : some View { DeviceTypeContent(deviceType: self) }

    func icon(forHeader: Bool) -> some View {
        symbolIcon(productFamily.symbolName, forHeader: forHeader)
    }

    func linkedForDeviceStyle(from model: SimModel) -> some Node {
        NodeLink(self) {
            model.runtimes.supporting(deviceType: self).map { runtime in
                runtime.linkedForDeviceStyle(from: model, deviceType: self)
            }
        }
    }
    
    func linkedForRuntimeStyle(from model: SimModel, runtime: SimRuntime) -> some Node {
        var node = NodeLink(self, items: runtime.devices.nodesFor(deviceType: self))
        
        return node.onUpdate { update in
            guard let runtime   = model.runtimes.supporting(deviceType: self).first(where: { $0 == update.runtime }) else { return nil }
            let ourAdditions    = update.additions.filter({ $0.deviceTypeIdentifier == identifier })
            let ourRemovals     = update.removals.filter({ $0.deviceTypeIdentifier == identifier })
            
            if !ourAdditions.isEmpty || !ourRemovals.isEmpty {
                return runtime.devices.nodesFor(deviceType: self)
            }
            else {
                return nil
            }
        }
    }
}
