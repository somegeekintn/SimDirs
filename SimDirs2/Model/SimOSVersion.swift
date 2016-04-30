//
//  SimOSVersion.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimOSVersion {
	let name			: String
	var devices			= [SimDevice]()

	init(name: String, deviceInfo: [String : AnyObject]) {
		self.name = name
	}
	
	func updateWithDeviceInfo(deviceInfo: [String : AnyObject], baseURL: NSURL) {
		guard let deviceName	= deviceInfo["name"] as? String else { return }
		guard let deviceUDID	= deviceInfo["UDID"] as? String else { return }
		let device				= SimDevice(name: deviceName, udid: deviceUDID, baseURL: baseURL)

		self.devices.append(device)
	}
}
