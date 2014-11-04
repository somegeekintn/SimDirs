//
//  QSSimAppInfo.m
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSSimAppInfo.h"


@interface QSSimAppInfo ()

@property (nonatomic, strong) NSArray		*childItems;

@end


@implementation QSSimAppInfo

- (id) initWithBundleID: (NSString *) inBundleID
{
	if ((self = [super init]) != nil) {
		self.bundleID = inBundleID;
	}
	
	return self;
}

- (NSString *) description
{
//	return [NSString stringWithFormat: @"%@: bundle %@ sandbox %@", self.bundleID, [self.bundlePath lastPathComponent], [self.sandBoxPath lastPathComponent]];
	return self.bundleID;
}

- (BOOL) testPath: (NSString *) inPath
{
	return inPath != nil && [[NSFileManager defaultManager] fileExistsAtPath: inPath] ? YES : NO;
}

- (void) updateFromLastLaunchMapInfo: (NSDictionary *) inMapInfo
{
	self.bundlePath = inMapInfo[@"BundleContainer"];
	self.sandBoxPath = inMapInfo[@"Container"];
}

- (void) updateFromAppStateInfo: (NSDictionary *) inStateInfo
{
	NSDictionary	*compatInfo = inStateInfo[@"compatibilityInfo"];
	
	if (compatInfo != nil) {
		self.bundlePath = compatInfo[@"bundlePath"];
		self.sandBoxPath = compatInfo[@"sandboxPath"];
	}
}

- (void) refinePaths
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*infoURL;
	
	if (self.bundlePath != nil && [[self.bundlePath lastPathComponent] rangeOfString: @".app"].location == NSNotFound) {
		NSURL					*bundleURL = [[NSURL alloc] initFileURLWithPath: self.bundlePath];
		NSURL					*appURL;
		NSDirectoryEnumerator	*dirEnum = [fileManager enumeratorAtURL: bundleURL includingPropertiesForKeys: nil
													options: NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];

		while ((appURL = [dirEnum nextObject])) {
			NSString	*appPath = [appURL path];
			
			if ([[appPath lastPathComponent] rangeOfString: @".app"].location != NSNotFound) {
				// setter won't let us reset so access ivar directly
				_bundlePath = appPath;
				_childItems = nil;
				break;
			}
		}
	}
	
	infoURL = [[NSURL alloc] initFileURLWithPath: self.bundlePath];
	infoURL = [infoURL URLByAppendingPathComponent: @"Info.plist"];
	if (infoURL != nil && [fileManager fileExistsAtPath: [infoURL path]]) {
		NSData		*plistData = [NSData dataWithContentsOfURL: infoURL];

		if (plistData != nil) {
			NSDictionary	*plistInfo;
			
			plistInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
			if (plistInfo != nil) {
				[self discoverAppInfoFromPList: plistInfo];
			}
		}
	}
}

- (void) discoverAppInfoFromPList: (NSDictionary *) inPListInfo
{
	NSDictionary	*bundleIcons = inPListInfo[@"CFBundleIcons"];
	
	self.appName = inPListInfo[(__bridge NSString *)kCFBundleNameKey];
	self.appShortVersion = inPListInfo[@"CFBundleShortVersionString"];
	self.appVersion = inPListInfo[(__bridge NSString *)kCFBundleVersionKey];
	
	if (bundleIcons != nil) {
		NSArray			*bundleIconFiles = bundleIcons[@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
		
		if (bundleIconFiles) {
			for (NSString *iconName in bundleIconFiles) {
				NSString	*fullIconName = iconName;
				NSURL		*iconURL;
				
				if (![iconName.pathExtension length]) {
					fullIconName = [iconName stringByAppendingPathExtension: @"png"];
				}
				iconURL = [[[NSURL alloc] initFileURLWithPath: self.bundlePath] URLByAppendingPathComponent: fullIconName];
				self.appIcon = [self imageAtURL: iconURL withMinimumWidth: 32.0];

				if (self.appIcon == nil) {
					fullIconName = [NSString stringWithFormat: @"%@@2x.png", iconName];
					iconURL = [[[NSURL alloc] initFileURLWithPath: self.bundlePath] URLByAppendingPathComponent: fullIconName];
					self.appIcon = [self imageAtURL: iconURL withMinimumWidth: 32.0];
					if (self.appIcon != nil) {
						break;
					}
				}
				else {
					break;
				}
			}
		}
	}
}

- (NSImage *) imageAtURL: (NSURL *) inImageURL
	withMinimumWidth: (CGFloat) inMinWidth
{
	NSImage		*image = nil;
	
	if (inImageURL != nil && [[NSFileManager defaultManager] fileExistsAtPath: [inImageURL path]]) {
		image = [[NSImage alloc] initWithContentsOfURL: inImageURL];
		if (image != nil) {
			if (image.size.width < inMinWidth) {
				image = nil;
			}
		}
	}
	
	return image;
}

#pragma mark - QSOutlineProvider

- (NSInteger) outlineChildCount
{
	return [self.childItems count];
}

- (id) outlineChildAtIndex: (NSInteger) inIndex
{
	NSDictionary		*pathInfo = [self.childItems objectAtIndex: inIndex];

	return pathInfo[@"title"];
}

- (BOOL) outlineItemIsExpanable
{
	return [self outlineChildCount] ? YES : NO;
}

- (NSString *) outlineItemTitle
{
	return self.title;
}

- (NSImage *) outlineItemImage
{
	return self.appIcon;
}

- (BOOL) outlineItemPerformAction
{
	return NO;
}

- (BOOL) outlineItemPerformActionForChild: (id) inChild
{
	NSInteger		pathIndex;
	BOOL			handled = NO;
	
	pathIndex = [self.childItems indexOfObjectPassingTest: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
		NSDictionary		*pathInfo = inObject;
		
		*outStop = [pathInfo[@"title"] isEqualToString: inChild];

		return *outStop;
	}];
	
	if (pathIndex != NSNotFound) {
		NSDictionary	*pathInfo = [self.childItems objectAtIndex: pathIndex];
		NSURL			*itemPathURL = [[NSURL alloc] initFileURLWithPath: pathInfo[@"path"]];

		if (itemPathURL != nil) {
			[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[ itemPathURL ]];
		}
		handled = YES;
	}
	
	return handled;
}

#pragma mark - Setters / Getters

- (NSArray *) childItems
{
	// any more than these two items and perhaps a dedicated class would be better
	
	if (_childItems == nil) {
		NSMutableArray		*childItems = [NSMutableArray array];
		
		if (self.bundlePath != nil) {
			[childItems addObject: @{ @"title" : @"Bundle Location", @"path" : self.bundlePath }];
		}
		if (self.sandBoxPath != nil) {
			[childItems addObject: @{ @"title" : @"Sandbox Location", @"path" : self.sandBoxPath }];
		}
		
		_childItems = childItems;
	}
	
	return _childItems;
}

- (void) setBundlePath: (NSString *) inBundlePath
{
	if (_bundlePath == nil && [self testPath: inBundlePath]) {
		_bundlePath = inBundlePath;
		_childItems = nil;
	}
}

- (void) setSandBoxPath: (NSString *) inSandBoxPath
{
	if (_sandBoxPath == nil && [self testPath: inSandBoxPath]) {
		_sandBoxPath = inSandBoxPath;
		_childItems = nil;
	}
}

- (NSString *) title
{
	NSString	*title;
	
	if (self.appName != nil) {
		title = [NSString stringWithFormat: @"%@ v%@", self.appName, self.appShortVersion];
		if (![self.appShortVersion isEqualToString: self.appVersion]) {
			title = [title stringByAppendingString: [NSString stringWithFormat: @" (%@)", self.appVersion]];
		}
		title = [title stringByAppendingString: [NSString stringWithFormat: @" - %@", self.bundleID]];
	}
	else {
		title = self.bundleID;
	}
	
	return title;
}

- (BOOL) hasValidPaths
{
	return [self.childItems count] ? YES : NO;
}

@end
