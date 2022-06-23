//
//  RuntimeHeader.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimRuntime {
    public var header : some View { RuntimeHeader(runtime: self) }
}

struct RuntimeHeader: View {
    var runtime         : SimRuntime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            if !runtime.buildversion.isEmpty {
                Text("Build Version: \(runtime.buildversion)")
            }
        }
        .font(.subheadline)
        .textSelection(.enabled)
    }
}

struct RuntimeHeader_Previews: PreviewProvider {
    static var runtimes    = SimModel().runtimes
    
    static var previews: some View {
        RuntimeContent(runtime: runtimes[0])
    }
}
