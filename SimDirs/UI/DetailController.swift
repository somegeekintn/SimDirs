//
//  DetailController.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/1/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

struct SimProperty {
	enum Value {
		 case Text(text: String)
		 case Location(url: URL)
	}

	let title		: String
	let value		: Value
	
	init(title: String, value: Value) {
		self.title = title
		self.value = value
	}
}

protocol PropertyProvider: AnyObject {
	var header		: String { get }
	var image		: NSImage? { get }
	var properties	: [SimProperty] { get }
}

class EmptyProvider: PropertyProvider {
	let header		= ""
	let image		: NSImage? = nil
	let properties	= [SimProperty]()
}

class DetailController: NSViewController, NSTableViewDataSource, NSTableViewDelegate  {
	@IBOutlet weak var headerLabel		: NSTextField!
	@IBOutlet weak var imageView		: NSImageView!
	@IBOutlet weak var propertyTable	: NSTableView!
	let emptyProvider					= EmptyProvider()
	var selectedItem					: Any? { didSet { self.reload() } }
	var selectedProvider				: PropertyProvider { return (self.selectedItem as? PropertyProvider) ?? self.emptyProvider }

	override func viewDidLoad() {
		super.viewDidLoad()
	
		self.reload()
	}
	
	func reload() {
		self.headerLabel.stringValue = self.selectedProvider.header
		self.imageView.image = self.selectedProvider.image
		self.propertyTable.reloadData()
	}
	
	// MARK: - NSTableViewDataSource -
	
    func numberOfRows(in tableView: NSTableView) -> Int {
		return self.selectedProvider.properties.count
	}

	// MARK: - NSTableViewDelegate -

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let selectedProperty	= self.selectedProvider.properties[row]
		let columnIdentifier	= tableColumn?.identifier ?? NSUserInterfaceItemIdentifier("")
		let view				: NSView?
		
		switch columnIdentifier.rawValue {
			case "value":
				switch selectedProperty.value {
					case .Text(let text):
                        view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("PropertyValueCell"), owner: self)
						(view as? NSTableCellView)?.textField?.stringValue = text
					
					case .Location(let url):
						view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("PropertyActionCell"), owner: self)
						if let actionCell = view as? ActionCell {
                            actionCell.action = { NSWorkspace.shared.activateFileViewerSelecting([url]) }
						}
				}
			
			default:
				view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("PropertyTitleCell"), owner: self)
				(view as? NSTableCellView)?.textField?.stringValue = selectedProperty.title
		}
		
		return view
	}
}
