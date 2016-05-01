//
//  SimOSVersion.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimOSVersion: OutlineProvider {
	let name			: String
	var devices			= [SimDevice]()

	init(name: String, deviceInfo: [String : AnyObject]) {
		self.name = name
	}
	
	func completeScan(platformName: String) {
		for device in self.devices {
			device.completeScan(platformName)
		}
		self.devices.sortInPlace { $0.name < $1.name }
	}
	
	func updateWithDeviceInfo(deviceInfo: [String : AnyObject], baseURL: NSURL) {
		guard let deviceName	= deviceInfo["name"] as? String else { return }
		guard let deviceUDID	= deviceInfo["UDID"] as? String else { return }
		guard var deviceType	= deviceInfo["deviceType"] as? String else { return }

		deviceType = deviceType.stringByReplacingOccurrencesOfString("com.apple.CoreSimulator.SimDeviceType.", withString: "")
		deviceType = deviceType.stringByReplacingOccurrencesOfString("-", withString: " ")

		self.devices.append(SimDevice(name: deviceName, type: deviceType, udid: deviceUDID, baseURL: baseURL))
	}

	// MARK: - OutlineProvider -
	
	var outlineTitle	: String { return self.name }
	var outlineImage	: NSImage? { return nil }
	var childCount		: Int { return self.devices.count }
	
	func childAtIndex(index: Int) -> OutlineProvider? {
		return self.devices[index]
	}
}
