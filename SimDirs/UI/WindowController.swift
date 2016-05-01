//
//  WindowController.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/1/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
		self.window?.setFrameAutosaveName("main")
    }

}
