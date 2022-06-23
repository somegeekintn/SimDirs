//
//  Helpers.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/31/22.
//

import SwiftUI

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

extension OptionSet where Self == Self.Element {
    func settingBool(_ value: Bool, options: Self) -> Self {
        if value { return union(options) }
        else { return subtracting (options) }
    }
    
    mutating func booleanSet(_ value: Bool, options: Self) {
        if value { update(with: options) }
        else { subtract(options) }
    }
}

extension ProcessInfo {
    var isPreviewing    : Bool { environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}

extension PropertyListSerialization {
	class func propertyList(from url: URL) -> [String : AnyObject]? {
        guard let plistData	= try? Data(contentsOf: url) else { return nil }

        return try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String : AnyObject]
	}
}

extension View {
    @ViewBuilder
    func evalIf<V: View>(_ test: Bool, then transform: (Self) -> V) -> some View {
        if test {
            transform(self)
        }
        else {
            self
        }
    }
}
