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
		let fileMgr		= NSFileManager.defaultManager()
		var platforms	= [SimPlatform]()
		
		if let libraryURL = fileMgr.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first {
			let deviceURL = libraryURL.URLByAppendingPathComponent("Developer/CoreSimulator/Devices")
			
			if let dirEnumerator = fileMgr.enumeratorAtURL(deviceURL, includingPropertiesForKeys: nil, options: [ .SkipsSubdirectoryDescendants, .SkipsHiddenFiles ], errorHandler: nil) {
				let dirURLs = dirEnumerator.allObjects.flatMap { $0 as? NSURL }
				
				for baseURL in dirURLs {
					let deviceURL			= baseURL.URLByAppendingPathComponent("device.plist")
					guard let deviceInfo	= NSPropertyListSerialization.propertyListWithURL(deviceURL) else { continue }
					guard let runtime		= deviceInfo["runtime"] as? String else { continue }
					let runtimeComponents	= runtime.stringByReplacingOccurrencesOfString("com.apple.CoreSimulator.SimRuntime.", withString: "").componentsSeparatedByString("-")

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
		
		return platforms.sort { $0.name < $1.name }
	}
	
	init(runtimeComponents: [String], deviceInfo: [String : AnyObject]) {
		self.name = runtimeComponents[0]
	}
	
	func completeScan() {
		for osVersion in self.osVersions {
			osVersion.completeScan()
		}
		self.osVersions.sortInPlace { $0.name > $1.name }
	}
	
	func updateWith(runtimeComponents: [String], deviceInfo: [String : AnyObject], baseURL: NSURL) {
		let versionID	= "\(runtimeComponents[safe: 1] ?? "0").\(runtimeComponents[safe: 2] ?? "0")"
		let osVersion	= self.osVersions.match({ $0.name == versionID }, orMake: { SimOSVersion(name: versionID, deviceInfo: deviceInfo) })
		
		osVersion.updateWithDeviceInfo(deviceInfo, baseURL: baseURL)
	}

	// MARK: - OutlineProvider -
	
	var outlineTitle	: String { return self.name }
	var outlineImage	: NSImage? { return nil }
	var childCount		: Int { return self.osVersions.count }
	
	func childAtIndex(index: Int) -> OutlineProvider? {
		return self.osVersions[index]
	}
}
