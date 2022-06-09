//
//  SimApp.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/1/22.
//

import SwiftUI

struct SimApp: Equatable {
    let identifier      : String
    let bundleID        : String
    let bundleName      : String
    let displayName     : String
    let version         : String
    let minOSVersion    : String
    let bundlePath      : String
    let sandboxPath     : String?
    let nsIcon          : NSImage?
    
    init(bundlePath: URL, sandboxPaths: [String : URL]) throws {
        guard let infoPList	= PropertyListSerialization.propertyList(from: bundlePath.appendingPathComponent("Info.plist")) else { throw SimError.invalidApp }
        guard let bundleID = infoPList[kCFBundleIdentifierKey as String] as? String else { throw SimError.invalidApp }
        
        self.bundlePath = bundlePath.path
        self.bundleID = bundleID
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
}

extension SimApp: PresentableItem, Identifiable {
    var title       : String { return displayName }
    var id          : String { return identifier }

    var imageName   : String { return "questionmark.app.dashed" }
    var icon        : NSImage? { return nsIcon }
}
