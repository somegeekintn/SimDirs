//
//  DetailTableView.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/1/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

class DetailTableView: NSTableView {
	override func drawGridInClipRect(clipRect: NSRect) {
		let lastRowRect		= self.rectOfRow(self.numberOfRows - 1)
		let adjClipRect		= NSRect(x: 0.0, y: 0.0, width: lastRowRect.width, height: lastRowRect.maxY)
	
		super.drawGridInClipRect(NSIntersectionRect(clipRect, adjClipRect))
	}
}
