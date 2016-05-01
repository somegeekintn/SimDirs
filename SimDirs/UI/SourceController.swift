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
	@IBOutlet weak var outlineView	: NSOutlineView!
	private var platforms			= [SimPlatform]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.rescan(nil)
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
		if let thing = (self.parentViewController as? NSSplitViewController)?.splitViewItems[safe: 1]?.viewController as? DetailController {
			var selectedItem	: AnyObject? = nil
			let row				= self.outlineView.selectedRow
			
			if row != NSNotFound {
				selectedItem = self.outlineView.itemAtRow(row)
			}
			
			thing.selectedItem = selectedItem
		}
	}
	
	// MARK: - Interaction -

	@IBAction func rescan(sender: AnyObject?) {
		self.platforms = SimPlatform.scan()
		self.outlineView.reloadData()
	}
}
