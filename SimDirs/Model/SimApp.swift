//
//  SimApp.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Foundation

class SimApp: OutlineProvider, PropertyProvider {
	let bundleID						: String
	var bundleName						= ""
	var displayName						= ""
	var shortVersion					= ""
	var version							= ""
	var minOSVersion					: String?
	var icon							: NSImage?
	var hasValidPaths					: Bool { return self.validatedBundlePath != nil || self.validatedSandboxPath != nil }
	var bundleURL						: URL? { return self.validatedBundlePath.map { URL(fileURLWithPath: $0) } }
	var sandboxURL						: URL? { return self.validatedSandboxPath.map { URL(fileURLWithPath: $0) } }
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
	
	func completeScan() {
		self.refinePaths()
		self.loadInfoPlist()
	}
	
	func updateFrom(launchBundleInfo: [String : AnyObject]) {
		self.bundlePath = launchBundleInfo["BundleContainer"] as? String
		self.sandboxPath = launchBundleInfo["Container"] as? String
	}
	
	func updateFrom(appStateInfo: [String : AnyObject]) {
		guard let compatInfo = appStateInfo["compatibilityInfo"] as? [String : AnyObject] else { return }

		self.bundlePath = compatInfo["bundlePath"] as? String
		self.sandboxPath = compatInfo["sandboxPath"] as? String
	}
	
	func refinePaths() {
		guard let bundleURL		= self.bundleURL else { return }
        let fileMgr				= FileManager.default
		
		if !bundleURL.lastPathComponent.contains("app") {
			if let dirEnumerator = fileMgr.enumerator(at: bundleURL, includingPropertiesForKeys: nil, options: [ .skipsSubdirectoryDescendants, .skipsHiddenFiles ]) {

				for appURL in dirEnumerator.allObjects.compactMap({ $0 as? URL}) {
					if appURL.lastPathComponent.contains(".app") {
						self.validatedBundlePath = appURL.path
						break
					}
				}
			}
		}
	}

	func loadInfoPlist() {
		guard let bundleURL		= self.bundleURL else { return }
		let infoPlistURL		= bundleURL.appendingPathComponent("Info.plist")

		if let plistInfo = PropertyListSerialization.propertyListWithURL(infoPlistURL) {
			self.bundleName = plistInfo[String(kCFBundleNameKey)] as? String ?? ""
			self.displayName = plistInfo["CFBundleDisplayName"] as? String ?? ""
			self.shortVersion = plistInfo["CFBundleShortVersionString"] as? String ?? ""
			self.version = plistInfo[String(kCFBundleVersionKey)] as? String ?? ""
			self.minOSVersion = plistInfo["MinimumOSVersion"] as? String
			
			if self.displayName.isEmpty {
				self.displayName = self.bundleName
			}
			
			if let bundleIcons = plistInfo["CFBundleIcons"] as? [String : AnyObject] {
				let primaryIconValue = bundleIcons["CFBundlePrimaryIcon"].flatMap { item -> [String : AnyObject]? in
					switch item {
						case let dict as [String : AnyObject]:	return dict
						case let str as String:					return ["CFBundleIconFiles" : [str]] as [String : AnyObject]
						default:								return nil
					}
				}
				
				if let primaryIcon = primaryIconValue {
					if let bundleIconFiles = primaryIcon["CFBundleIconFiles"] as? [String] {
						for iconName in bundleIconFiles {
							var iconURL		= bundleURL.appendingPathComponent(iconName)
							let icon2XURL	= bundleURL.appendingPathComponent("\(iconName)@2x.png")
							
							if iconURL.pathExtension.isEmpty {
								iconURL = iconURL.appendingPathComponent("png")
							}
							
// .car files not yet working :/

//							if !iconURL.validPath && !icon2XURL.validPath {		// Believe this would only happen once per bundle
//								let assetFileURL	= bundleURL.URLByAppendingPathComponent("Assets.car")
//								
//								if assetFileURL.validPath {
//									if let catalog = try? CUICatalog.init(URL: assetFileURL) {
//										let catalogImages = catalog.imagesWithName(iconName)
//										
//										for catalogImage in catalogImages {
//											if let namedImage = catalogImage as? CUINamedImage where !(namedImage is CUINamedLayerStack) {
//												if self.icon?.size.width ?? 0 < namedImage.size.width {
//													let imageRep = NSBitmapImageRep(CGImage: namedImage.image)
//													
//													imageRep.size = namedImage.size
//													if let pngData = imageRep.representationUsingType(.NSPNGFileType, properties: [NSImageInterlaced : false]) where pngData.length > 0 {
//														self.icon = NSImage(data: pngData)
//													}
//													self.icon = NSImage(CGImage: namedImage.image, size: namedImage.size)
//												}
//											}
//										}
//									}
//								}
//							}
//							else {
								if let icon = NSImage(contentsOf: iconURL) {
									if self.icon?.size.width ?? 0 < icon.size.width {
										self.icon = icon
									}
								}
								
								if let icon = NSImage(contentsOf: icon2XURL) {
									if self.icon?.size.width ?? 0 < icon.size.width {
										self.icon = icon
									}
								}
//							}
						}
					}
				}
			}
			
			if self.icon == nil {
				self.icon = NSImage(named: "default_icon")
			}
		}
	}

	// MARK: - OutlineProvider -
	
	var outlineTitle	: String { return self.displayName }
	var outlineImage	: NSImage? { return self.icon }
	var childCount		: Int { return 0 }
	
	func childAt(index: Int) -> OutlineProvider? {
		return nil
	}
	
	// MARK: - PropertyProvider -
	
	var header		: String { return "App Information" }
	var image		: NSImage? { return self.icon }
	var properties	: [SimProperty] {
		var version		= self.shortVersion
		var properties	: [SimProperty]
		
		if self.shortVersion != self.version {
			version += " \((self.version))"
		}
		
		properties = [
			SimProperty(title: "Display Name", value: .Text(text: self.displayName)),
			SimProperty(title: "Bundle Name", value: .Text(text: self.bundleName)),
			SimProperty(title: "Bundle ID", value: .Text(text: self.bundleID)),
			SimProperty(title: "Version", value: .Text(text: version))
		]
		if let minOSVersion = self.minOSVersion {
			properties.append(SimProperty(title: "Minimum OS Version", value: .Text(text: minOSVersion)))
		}
		if let bundleURL = self.bundleURL {
			properties.append(SimProperty(title: "Bundle", value: .Location(url: bundleURL)))
		}
		if let sandboxURL = self.sandboxURL {
			properties.append(SimProperty(title: "Sandbox", value: .Location(url: sandboxURL)))
		}

		return properties
	}
}
