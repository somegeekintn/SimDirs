//
//  PathActions.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/31/22.
//

import SwiftUI

struct PathActions: View {
    var path         : String

    var body: some View {
        // ControlGroup almost but not quite what we want
        HStack {
            Button(action: { NSPasteboard.copy(text: path) }) {
                Image(systemName: "doc.on.doc") }
            Divider()
                .frame(height: 16.0)
            Button(action: { NSWorkspace.reveal(filepath: path) }) {
                Image(systemName: "arrow.right.circle.fill") }
        }
        .buttonStyle(.borderless)
        .padding(.vertical, 4.0)
        .padding(.horizontal, 8.0)
        .overlay(RoundedRectangle(cornerRadius: 6.0)
            .stroke(.white.opacity(0.4), lineWidth: 1.0))
        .background(.black.opacity(0.4))
        .cornerRadius(6.0)
    }
}

struct PathActions_Previews: PreviewProvider {
    static var previews: some View {
        PathActions(path: "~/Desktop")
    }
}
