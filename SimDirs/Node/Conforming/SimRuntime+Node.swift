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
}
