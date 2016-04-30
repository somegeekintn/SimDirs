//
//  SimApp.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimApp {
	let bundleID						: String
	var name							= ""
	var shortVersion					= ""
	var version							= ""
	var icon							: NSImage?
	var hasValidPaths					: Bool { return self.validatedBundlePath != nil || self.validatedSandboxPath != nil }
	var bundleURL						: NSURL? { return self.validatedBundlePath.map { NSURL(fileURLWithPath: $0) } }
	var sandboxURL						: NSURL? { return self.validatedSandboxPath.map { NSURL(fileURLWithPath: $0) } }
	private var validatedBundlePath		: String?
	private var validatedSandboxPath	: String?
	
	var bundlePath						: String? {
		get { return self.validatedBundlePath }
		set {
			guard let newPath = newValue else { return }
			if self.validatedBundlePath == nil && newPath.validPath {
				self.validatedBundlePath = newPath
			}
		}
	}
	var sandboxPath						: String? {
		get { return self.validatedSandboxPath }
		set {
			guard let newPath = newValue else { return }
			if self.validatedSandboxPath == nil && newPath.validPath {
				self.validatedSandboxPath = newPath
			}
		}
	}
	
	init(bundleID: String) {
		self.bundleID = bundleID
	}
	
	func updateFromLastLaunchMapInfo(launchBundleInfo: [String : AnyObject]) {
		self.bundlePath = launchBundleInfo["BundleContainer"] as? String
		self.sandboxPath = launchBundleInfo["Container"] as? String
	}
	
	func updateFromAppStateInfo(appStateInfo: [String : AnyObject]) {
		guard let compatInfo = appStateInfo["compatibilityInfo"] as? [String : AnyObject] else { return }

		self.bundlePath = compatInfo["bundlePath"] as? String
		self.sandboxPath = compatInfo["sandboxPath"] as? String
	}
	
	func completeInitialization() {
		self.refinePaths()
		self.loadInfoPlist()
	}
	
	func refinePaths() {
		guard let bundleURL		= self.bundleURL else { return }
		let fileMgr				= NSFileManager.defaultManager()
		
		if let lastPathComponent = bundleURL.lastPathComponent where !lastPathComponent.containsString(".app") {
			if let dirEnumerator = fileMgr.enumeratorAtURL(bundleURL, includingPropertiesForKeys: nil, options: [ .SkipsSubdirectoryDescendants, .SkipsHiddenFiles ], errorHandler: nil) {
				let dirURLs = dirEnumerator.allObjects.flatMap { $0 as? NSURL }
				
				for appURL in dirURLs {
					guard let lastPathComponent = appURL.lastPathComponent else { continue }
					
					if lastPathComponent.containsString(".app") {
						self.validatedBundlePath = appURL.path
						break
					}
				}
			}
		}
	}

	func loadInfoPlist() {
		guard let bundleURL		= self.bundleURL else { return }
		let infoPlistURL		= bundleURL.URLByAppendingPathComponent("Info.plist")
//		let assetFileURL		= bundleURL.URLByAppendingPathComponent("Assets.car")

		if let plistInfo = NSPropertyListSerialization.propertyListWithURL(infoPlistURL) {
			self.name = plistInfo[String(kCFBundleNameKey)] as? String ?? ""
			self.shortVersion = plistInfo["CFBundleShortVersionString"] as? String ?? ""
			self.version = plistInfo[String(kCFBundleVersionKey)] as? String ?? ""

//			if assetFileURL.validPath {
//				if let catalog = try? CUICatalog.init(URL: assetFileURL) {
//print("\(catalog.allImageNames)")
//				}
//			}
			
			if let bundleIcons = plistInfo["CFBundleIcons"] as? [String : AnyObject] {
				if let primaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
					if let bundleIconFiles = primaryIcon["CFBundleIconFiles"] as? [String] {
						for iconName in bundleIconFiles {
							var iconURL		= bundleURL.URLByAppendingPathComponent(iconName)
							let icon2XURL	= bundleURL.URLByAppendingPathComponent("\(iconName)@2x.png")
							let missingExt	= iconURL.pathExtension.map({ return $0.isEmpty }) ?? true
							
							if missingExt {
								iconURL = iconURL.URLByAppendingPathExtension("png")
							}
							
							if let icon = NSImage(contentsOfURL: iconURL) {
								if self.icon?.size.width ?? 0 < icon.size.width {
									self.icon = icon
								}
							}
							
							if let icon = NSImage(contentsOfURL: icon2XURL) {
								if self.icon?.size.width ?? 0 < icon.size.width {
									self.icon = icon
								}
							}
						}
					}
				}
			}
			
			if self.icon == nil {
				self.icon = NSImage(named: "defaultIcon")
			}
		}
	}
}
