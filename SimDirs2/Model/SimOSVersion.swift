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
	
	func completeScan() {
		for device in self.devices {
			device.completeScan()
		}
		self.devices.sortInPlace { $0.name < $1.name }
	}
	
	func updateWithDeviceInfo(deviceInfo: [String : AnyObject], baseURL: NSURL) {
		guard let deviceName	= deviceInfo["name"] as? String else { return }
		guard let deviceUDID	= deviceInfo["UDID"] as? String else { return }
		let device				= SimDevice(name: deviceName, udid: deviceUDID, baseURL: baseURL)

		self.devices.append(device)
	}

	// MARK: - OutlineProvider -
	
	var outlineTitle	: String { return self.name }
	var outlineImage	: NSImage? { return nil }
	var childCount		: Int { return self.devices.count }
	
	func childAtIndex(index: Int) -> OutlineProvider? {
		return self.devices[index]
	}
}
