//
//  SimDevice+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimDevice: Node {
    var title       : String { return name }
    var headerTitle : String { "Device: \(title)" }
    
    var header      : some View { DeviceHeader(device: self) }
    var content     : some View { DeviceContent(self) }

//    var isEnabled   : Bool { isBooted }
    var iconName    : String { deviceType?.productFamily.symbolName ?? "questionmark.circle" }
    var items       : [SimApp]? {
        get { apps }
        set { apps = newValue ?? [] }
    }

    func icon(forHeader: Bool) -> some View {
        symbolIcon(iconName, color: isAvailable ? .green : .red, forHeader: forHeader)
    }
    
    func matchedFilterOptions() -> SourceFilter.Options {
        return !apps.isEmpty ? .withApps : []
    }
}
