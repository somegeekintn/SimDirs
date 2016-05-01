//
//  AppDelegate.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/29/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(aNotification: NSNotification) {
	}

	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}
}

