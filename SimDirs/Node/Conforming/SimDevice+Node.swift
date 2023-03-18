//
//  SimDevice+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

// SimDevice requires a wrapper to simulate Node conformance because its
// icon is provided by a SimDeviceType

struct SimDeviceNode: Node {
    let device      : SimDevice
    var iconName    : String

    var title       : String { device.name }
    var headerTitle : String { "Device: \(title)" }
    var header      : some View { DeviceHeader(device) }
    var content     : some View { DeviceContent(device) }
    var items       : [SimApp]? {
        get { device.apps }
        set { device.apps = newValue ?? [] }
    }

    init(_ device: SimDevice, iconName: String) {
        self.device = device
        self.iconName = iconName
    }
    
    func icon(forHeader: Bool) -> some View {
        symbolIcon(iconName, color: device.isAvailable ? .green : .red, forHeader: forHeader)
    }
    
    func matchedFilterOptions() -> SourceFilter.Options {
        return !device.apps.isEmpty ? .withApps : []
    }
}

extension Array where Element == SimDevice {
    func nodesFor(deviceType: SimDeviceType) -> [SimDeviceNode] {
        filter({ $0.isDeviceOfType(deviceType) }).map({ SimDeviceNode($0, iconName: deviceType.productFamily.symbolName) })
    }
}
