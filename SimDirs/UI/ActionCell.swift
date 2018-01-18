//
//  ActionCell.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/1/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

class ActionCell: NSView {
	@IBOutlet weak var actionButton	: NSButton!
	var action						: (() -> ())?
	
	@IBAction func executeAction(_ sender: AnyObject) {
		action?()
	}
}
