//
//  SimProductFamily+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimProductFamily: Node {
    var title       : String { self.rawValue }
    var headerTitle : String { "Product Family: \(title)" }

    var header      : some View { get { EmptyView() } }
    var content     : some View { get { EmptyView() } }

    func icon(forHeader: Bool) -> some View {
        symbolIcon(symbolName, forHeader: forHeader)
    }
    
    func linked(from model: SimModel) -> some Node {
        NodeLink(self) {
            model.deviceTypes.supporting(productFamily: self).map { deviceType in
                deviceType.linkedForDeviceStyle(from: model)
            }
        }
    }
}
