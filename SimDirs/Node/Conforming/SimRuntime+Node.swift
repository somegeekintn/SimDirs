//
//  SimRuntime+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimRuntime: Node {
    var title           : String { return name }
    var headerTitle     : String { "Runtime: \(title)" }
    
    var header          : some View { RuntimeHeader(runtime: self) }
    var content         : some View { RuntimeContent(runtime: self) }

    func icon(forHeader: Bool) -> some View {
        symbolIcon("shippingbox", color: isAvailable ? .green : .red, forHeader: forHeader)
    }

    func matchedFilterOptions() -> SourceFilter.Options {
        return isAvailable ? .runtimeInstalled : []
    }

    func linkedForDeviceStyle(from model: SimModel, deviceType: SimDeviceType) -> some Node {
        var node = NodeLink(self) { devices.nodesFor(deviceType: deviceType) }
        
        return node.onUpdate { [weak self] update in
            guard let this = self else { return nil }
            guard update.runtime == this else { return nil }
            let ourAdditions    = update.additions.filter({ $0.deviceTypeIdentifier == deviceType.identifier })
            let ourRemovals = update.removals.filter({ $0.deviceTypeIdentifier == deviceType.identifier })

            if !ourAdditions.isEmpty || !ourRemovals.isEmpty {
                return this.devices.nodesFor(deviceType: deviceType)
            }
            else {
                return nil
            }
        }
    }

    func linkedForRuntimeStyle(from model: SimModel) -> some Node {
        NodeLink(self) {
            model.deviceTypes.supporting(runtime: self).map { devType in
                devType.linkedForRuntimeStyle(from: model, runtime: self)
            }
        }
    }
}
