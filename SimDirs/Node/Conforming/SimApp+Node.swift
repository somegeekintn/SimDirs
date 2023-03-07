//
//  SimApp+Node.swift
//  SimDirs
//
//  Created by Casey Fleser on 3/5/23.
//

import SwiftUI

extension SimApp: Node {
    var title       : String { return displayName }
    var headerTitle : String { "App: \(title)" }
    
    var header      : some View { AppHeader(app: self) }
    var content     : some View { AppContent(app: self) }

    func icon(forHeader: Bool) -> some View {
        if let nsIcon = nsIcon {
            let iconSize : CGFloat = forHeader ? 128 : 20
            
            Image(nsImage: nsIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(iconSize / 5.0)
                .shadow(radius: 4.0, x: 2.0, y: 2.0)
                .frame(maxWidth: iconSize, maxHeight: iconSize)
        }
        else {
            symbolIcon("questionmark.app.dashed", forHeader: forHeader)
        }
    }
    
}
