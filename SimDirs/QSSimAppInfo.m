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
	NSString	*path;
	
	path = inMapInfo[@"BundleContainer"];
	if (self.bundlePath == nil && [self testPath: path]) {
		self.bundlePath = path;
	}
	path = inMapInfo[@"Container"];
	if (self.sandBoxPath == nil && [self testPath: path]) {
		self.sandBoxPath = path;
	}
}

- (void) updateFromAppStateInfo: (NSDictionary *) inStateInfo
{
	NSDictionary	*compatInfo = inStateInfo[@"compatibilityInfo"];
	
	if (compatInfo != nil) {
		NSString	*path;
		
		path = compatInfo[@"bundlePath"];
		if (self.bundlePath == nil && [self testPath: path]) {
			self.bundlePath = path;
		}
		path = compatInfo[@"sandboxPath"];
		if (self.sandBoxPath == nil && [self testPath: path]) {
			self.sandBoxPath = path;
		}
	}
}

- (void) refinePaths
{
	NSURL		*infoURL;
	
	if (self.bundlePath != nil && [[self.bundlePath lastPathComponent] rangeOfString: @".app"].location == NSNotFound) {
		NSFileManager			*fileManager = [NSFileManager defaultManager];
		NSURL					*bundleURL = [[NSURL alloc] initFileURLWithPath: self.bundlePath];
		NSURL					*appURL;
		NSDirectoryEnumerator	*dirEnum = [fileManager enumeratorAtURL: bundleURL includingPropertiesForKeys: nil
													options: NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];

		while ((appURL = [dirEnum nextObject])) {
			NSString	*appPath = [appURL path];
			
			if ([[appPath lastPathComponent] rangeOfString: @".app"].location != NSNotFound) {
				self.bundlePath = appPath;
				break;
			}
		}
	}
	
	infoURL = [[NSURL alloc] initFileURLWithPath: self.bundlePath];
	infoURL = [infoURL URLByAppendingPathComponent: @"Info.plist"];
	if (infoURL != nil && [[NSFileManager defaultManager] fileExistsAtPath: [infoURL path]]) {
		NSData		*plistData = [NSData dataWithContentsOfURL: infoURL];

		if (plistData != nil) {
			NSDictionary	*plistInfo;
			
			plistInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
			if (plistInfo != nil) {
				self.appName = plistInfo[(__bridge NSString *)kCFBundleNameKey];
				self.appShortVersion = plistInfo[@"CFBundleShortVersionString"];
				self.appVersion = plistInfo[(__bridge NSString *)kCFBundleVersionKey];
			}
		}
	}
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

- (NSString *) outlineItemValueForColumn: (NSTableColumn *) inTableColumn
{
	return [inTableColumn.identifier isEqualToString: @"title"] ? self.title : nil;
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
	_bundlePath = inBundlePath;
	_childItems = nil;
}

- (void) setSandBoxPath: (NSString *) inSandBoxPath
{
	_sandBoxPath = inSandBoxPath;
	_childItems = nil;
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
