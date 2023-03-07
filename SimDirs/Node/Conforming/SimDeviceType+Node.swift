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
}
