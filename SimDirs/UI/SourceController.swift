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
	
	func childAt(index: Int) -> OutlineProvider?
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
	
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		return (item as? OutlineProvider)?.childCount ?? self.platforms.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return (item as? OutlineProvider)?.childAt(index: index) ?? self.platforms[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return (item as? OutlineProvider)?.expandable ?? (self.platforms.count > 0)
	}
	
	// MARK: - NSOutlineViewDelegate -
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view	: NSTableCellView? = nil
		var title	= ""
		var image	: NSImage? = nil
		
		if let outlineProvider = item as? OutlineProvider {
			title = outlineProvider.outlineTitle
			image = outlineProvider.outlineImage
		}
		
		if let outlineCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(image != nil ? "ImageCell" : "TextCell"), owner: self) as? NSTableCellView {
			outlineCell.textField?.stringValue = title
			outlineCell.imageView?.image = image
			view = outlineCell
		}
		
		return view
	}
	
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		return (item as? OutlineProvider)?.outlineImage != nil ? 24.0 : 20.0
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
        if let thing = (self.parent as? NSSplitViewController)?.splitViewItems[safe: 1]?.viewController as? DetailController {
			var selectedItem	: Any? = nil
			let row				= self.outlineView.selectedRow
			
			if row != NSNotFound {
				selectedItem = self.outlineView.item(atRow: row)
			}
			
			thing.selectedItem = selectedItem
		}
	}
	
	// MARK: - Interaction -

	@IBAction func rescan(_ sender: AnyObject?) {
		self.platforms = SimPlatform.scan()
		self.outlineView.reloadData()
	}
}
