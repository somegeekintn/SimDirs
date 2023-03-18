//
//  SimPlatform+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimPlatform: Node {
    var title       : String { self.rawValue }
    var headerTitle : String { "Platform: \(title)" }
    
    var header      : some View { get { EmptyView() } }
    var content     : some View { get { EmptyView() } }

    func icon(forHeader: Bool) -> some View {
        symbolIcon(symbolName, forHeader: forHeader)
    }

    func linked(from model: SimModel) -> some Node {
        NodeLink(self) {
            model.runtimes.supporting(platform: self).map { runtime in
                runtime.linkedForRuntimeStyle(from: model)
            }
        }
    }
}
