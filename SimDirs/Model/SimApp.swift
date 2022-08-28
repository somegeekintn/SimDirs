//
//  SimApp.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/1/22.
//

import SwiftUI

class SimApp: ObservableObject {
    @Published var state    = State.unknown
    @Published var pid      : Int?

    weak var device     : SimDevice?
    let identifier      : String
    let bundleID        : String
    let bundleName      : String
    let displayName     : String
    let version         : String
    let minOSVersion    : String
    let bundlePath      : String
    let sandboxPath     : String?
    let nsIcon          : NSImage?
    
    init(bundlePath: URL, sandboxPaths: [String : URL], device: SimDevice) throws {
        guard let infoPList	= PropertyListSerialization.propertyList(from: bundlePath.appendingPathComponent("Info.plist")) else { throw SimError.invalidApp }
        guard let bundleID = infoPList[kCFBundleIdentifierKey as String] as? String else { throw SimError.invalidApp }
        
        self.bundlePath = bundlePath.path
        self.bundleID = bundleID
        self.device = device
        bundleName = (infoPList[kCFBundleNameKey as String] as? String) ?? "<missing>"
        displayName = (infoPList["CFBundleDisplayName"] as? String) ?? bundleName
        version = (infoPList["CFBundleShortVersionString"] as? String) ?? "<missing>"
        minOSVersion = (infoPList["MinimumOSVersion"] as? String) ?? "<missing>"
        sandboxPath = sandboxPaths[bundleID]?.path
        identifier = bundlePath.deletingLastPathComponent().lastPathComponent
        
        // Currently using the biggest image we can find in pixels. Maybe there's a better way?
        nsIcon = (infoPList["CFBundleIcons"] as? [String : AnyObject]).flatMap { bundleIcons -> NSImage? in
            guard let iconFiles = bundleIcons["CFBundlePrimaryIcon"].map({ iconEntry -> [String] in
                                    switch iconEntry {
                                        case let primaryDict as [String : AnyObject]:   return primaryDict["CFBundleIconFiles"] as? [String] ?? []
                                        case let str as String:					        return [str]
                                        default:								        return []
                                    }
                                }) else { return nil }
            var icon            = NSImage()
            var pixelWidth      = 0
            var validIcon       = false
            
            for iconFile in iconFiles {
                let iconPathComps   : [String] = [iconFile, "\(iconFile)@2x", "\(iconFile)@3x"]

                for pathComp in iconPathComps {
                    var iconURL		= bundlePath.appendingPathComponent(pathComp)
                    
                    if iconURL.pathExtension.isEmpty {
                        iconURL.appendPathExtension("png")
                    }
                    
                    if let testIcon = NSImage(contentsOf: iconURL) {
                        for imageRep in testIcon.representations {
                            if pixelWidth < imageRep.pixelsWide {
                                icon = testIcon
                                pixelWidth = imageRep.pixelsWide
                                validIcon = true
                            }
                        }
                    }
                }
            }
            
            return validIcon ? icon : nil
        }
    }
    
    func discoverState() {
        Task {
            let result = try await SimCtl().getAppPID(self)

            await MainActor.run {
                pid = result
                state = pid != nil ? .launched : .terminated
            }
        }
    }
    
    func toggleLaunchState() {
        Task {
            switch state {
                case .launched:
                    try SimCtl().terminate(self)
                    
                    await MainActor.run {
                        pid = nil
                        state = .terminated
                    }
                    
                default:
                    let result = try await SimCtl().launch(self)
                    
                    await MainActor.run {
                        pid = result
                        state = pid != nil ? .launched : .terminated
                    }
            }
        }
    }
}

extension SimApp {
    enum State: String {
        case terminated     = "terminated"
        case launched       = "launched"
        case unknown        = "unknown"
        
        var isOn            : Bool { self == .launched }
    }
}

extension SimApp: SourceItemData {
    var title           : String { return displayName }
    var headerTitle     : String { "App: \(title)" }
    var imageDesc       : SourceImageDesc { nsIcon.map { .icon(nsImage: $0) } ?? .symbol(systemName: "questionmark.app.dashed") }

    var optionTrait     : SourceFilter.Options { .withApps }
}
