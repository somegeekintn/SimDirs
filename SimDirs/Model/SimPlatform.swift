//
//  SimPlatform.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimPlatform: OutlineProvider {
	let name			: String
	var osVersions		= [SimOSVersion]()
	
	class func scan() -> [SimPlatform] {
		let fileMgr		= FileManager.default
		var platforms	= [SimPlatform]()
		
        if let libraryURL = fileMgr.urls(for: .libraryDirectory, in: .userDomainMask).first {
			let deviceURL = libraryURL.appendingPathComponent("Developer/CoreSimulator/Devices")
			
			if let dirEnumerator = fileMgr.enumerator(at: deviceURL, includingPropertiesForKeys: nil, options: [ .skipsSubdirectoryDescendants, .skipsHiddenFiles ], errorHandler: nil) {
				for baseURL in dirEnumerator.allObjects.compactMap({ $0 as? URL }) {
					let deviceURL			= baseURL.appendingPathComponent("device.plist")
					guard let deviceInfo	= PropertyListSerialization.propertyListWithURL(deviceURL) else { continue }
					guard let runtime		= deviceInfo["runtime"] as? String else { continue }
					let runtimeComponents	= runtime.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "").split(separator: "-").map({ String($0) })

					if let platformName = runtimeComponents.first {
                        let platform	= platforms.match({ $0.name == platformName }, orMake: { SimPlatform(runtimeComponents: runtimeComponents, deviceInfo: deviceInfo) })
						
						platform.updateWith(runtimeComponents, deviceInfo: deviceInfo, baseURL: baseURL)
					}
				}
			}
		}
		
		for platform in platforms {
			platform.completeScan()
		}
		
		return platforms.sorted { $0.name < $1.name }
	}
	
	init(runtimeComponents: [String], deviceInfo: [String : AnyObject]) {
		self.name = runtimeComponents[0]
	}
	
	func completeScan() {
		for osVersion in self.osVersions {
            osVersion.completeScan(platformName: self.name)
		}
		self.osVersions.sort(by: { $0.name > $1.name })
	}
	
	func updateWith(_ runtimeComponents: [String], deviceInfo: [String : AnyObject], baseURL: URL) {
		let versionID	= "\(runtimeComponents[safe: 1] ?? "0").\(runtimeComponents[safe: 2] ?? "0")"
		let osVersion	= self.osVersions.match({ $0.name == versionID }, orMake: { SimOSVersion(name: versionID, deviceInfo: deviceInfo) })
		
		osVersion.updateWith(deviceInfo: deviceInfo, baseURL: baseURL)
	}

	// MARK: - OutlineProvider -
	
	var outlineTitle	: String { return self.name }
	var outlineImage	: NSImage? { return nil }
	var childCount		: Int { return self.osVersions.count }
	
	func childAt(index: Int) -> OutlineProvider? {
		return self.osVersions[index]
	}
}
