//
//  SimPlatform.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimPlatform {
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
	
		return platforms
	}
	
	init(runtimeComponents: [String], deviceInfo: [String : AnyObject]) {
		self.name = runtimeComponents[0]
	}
	
	func updateWith(runtimeComponents: [String], deviceInfo: [String : AnyObject], baseURL: NSURL) {
		let versionID	= "\(runtimeComponents[safe: 1] ?? "0").\(runtimeComponents[safe: 2] ?? "0")"
		let osVersion	= self.osVersions.match({ $0.name == versionID }, orMake: { SimOSVersion(name: versionID, deviceInfo: deviceInfo) })
		
		osVersion.updateWithDeviceInfo(deviceInfo, baseURL: baseURL)
	}
}
