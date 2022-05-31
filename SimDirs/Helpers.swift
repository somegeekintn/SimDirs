//
//  Helpers.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/31/22.
//

import AppKit

extension NSPasteboard {
    static func copy(text: String) {
        general.clearContents()
        general.setData(text.data(using: .utf8), forType: .string)
    }
}

extension NSWorkspace {
    static func reveal(filepath: String) {
        let filepathURL   = URL(fileURLWithPath: filepath)
        
        shared.activateFileViewerSelecting([filepathURL])
    }
}
