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
		 case text(text: String)
		 case location(url: URL)
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
	var selectedItem					: AnyObject? { didSet { self.reload() } }
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
		return self.selectedProvider.properties.count ?? 0
	}

	// MARK: - NSTableViewDelegate -

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let selectedProperty	= self.selectedProvider.properties[row]
		let columnIdentifier	= tableColumn?.identifier ?? ""
		let view				: NSView?
		
		switch columnIdentifier {
			case "value":
				switch selectedProperty.value {
					case .text(let text):
						view = tableView.make(withIdentifier: "PropertyValueCell", owner: self)
						(view as? NSTableCellView)?.textField?.stringValue = text
					
					case .location(let url):
						view = tableView.make(withIdentifier: "PropertyActionCell", owner: self)
						if let actionCell = view as? ActionCell {
							actionCell.action = { NSWorkspace.shared().activateFileViewerSelecting([url]) }
						}
				}
			
			default:
				view = tableView.make(withIdentifier: "PropertyTitleCell", owner: self)
				(view as? NSTableCellView)?.textField?.stringValue = selectedProperty.title
		}
		
		return view
	}
}
