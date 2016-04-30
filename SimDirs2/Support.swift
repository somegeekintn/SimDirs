//
//  Support.swift
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//
//	Assorted convenience extensions

import Foundation

extension Array {
	mutating func match(predicate: (Element) -> Bool, orMake: () -> Element) -> Element {
		let element	: Element
		
		if let index = self.indexOf(predicate) {
			element = self[index]
		}
		else {
			element = orMake()
			self.append(element)
		}
		
		return element
	}
}

extension CollectionType {
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
	var validPath	: Bool { return NSFileManager.defaultManager().fileExistsAtPath(self) }
}

extension NSURL {
	var validPath	: Bool { return self.path.map { NSFileManager.defaultManager().fileExistsAtPath($0) } ?? false  }
}

extension NSPropertyListSerialization {
	class func propertyListWithURL(url: NSURL) -> [String : AnyObject]? {
		guard let plistData	= NSData(contentsOfURL: url) else { return nil }
		let plist			: [String : AnyObject]?
		
		do {
			plist = try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: nil) as? [String : AnyObject]
		} catch {
			plist = nil
		}
		
		return plist
	}
}

