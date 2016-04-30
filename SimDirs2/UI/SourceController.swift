//
//  SourceController.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

protocol OutlineProvider: AnyObject {
	var outlineTitle	: String { get }
	var outlineImage	: NSImage? { get }
	var childCount		: Int { get }
	
	func childAtIndex(index: Int) -> OutlineProvider?
}

extension OutlineProvider {
	var expandable		: Bool { return self.childCount > 0 }
}

class SourceController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	var		platforms	= [SimPlatform]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.rescan()
	}
	
	func rescan() {
		self.platforms = SimPlatform.scan()
	}
	
	// MARK: - NSOutlineViewDataSource -
	
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		return (item as? OutlineProvider)?.childCount ?? self.platforms.count
	}
	
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		return (item as? OutlineProvider)?.childAtIndex(index) ?? self.platforms[index]
	}
	
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		return (item as? OutlineProvider)?.expandable ?? (self.platforms.count > 0)
	}
	
	// MARK: - NSOutlineViewDelegate -
	
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		var view	: NSTableCellView? = nil
		var title	= ""
		var image	: NSImage? = nil
		
		if let outlineProvider = item as? OutlineProvider {
			title = outlineProvider.outlineTitle
			image = outlineProvider.outlineImage
		}
		
		if let outlineCell = outlineView.makeViewWithIdentifier(image != nil ? "ImageCell" : "TextCell", owner: self) as? NSTableCellView {
			outlineCell.textField?.stringValue = title
			outlineCell.imageView?.image = image
			view = outlineCell
		}
		
		return view
	}
	
	func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
		return (item as? OutlineProvider)?.outlineImage != nil ? 24.0 : 20.0
	}
	
	func outlineViewSelectionDidChange(notification: NSNotification) {
		NSLog("boop")
	}
	
//- (void) outlineViewSelectionDidChange: (NSNotification *) inNotification
//{
//	NSInteger	row = [self.locationOutline selectedRow];
//	BOOL		selectedTab = NO;
//	
//	self.selectedDevice = nil;
//	self.selectedApp = nil;
//	
//	if (row != -1) {
//		id				item = [self.locationOutline itemAtRow: row];
//		
//		if ([item isKindOfClass: [QSSimDeviceInfo class]]) {
//			self.selectedDevice = item;
//			[self updateDeviceTabWithSelection];
//			
//			[self.infoTabView selectTabViewItemWithIdentifier: @"device"];
//			selectedTab = YES;
//		}
//		if ([item isKindOfClass: [QSSimAppInfo class]]) {
//			self.selectedApp = item;
//			[self updateAppTabWithSelection];
//			
//			[self.infoTabView selectTabViewItemWithIdentifier: @"app"];
//			selectedTab = YES;
//		}
//	}
//
//	if (!selectedTab) {
//		[self.infoTabView selectTabViewItemWithIdentifier: @"empty"];
//	}
//}
//
}
