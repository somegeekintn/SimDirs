//
//  AppDelegate.m
//  SimDirs
//
//  Created by Casey Fleser on 9/10/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, weak) IBOutlet NSWindow		*window;
@property (nonatomic, weak) IBOutlet NSOutlineView	*locationOutline;
@property (nonatomic, strong) NSMutableArray		*simLocations;

@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
	[self.locationOutline setDoubleAction: @selector(handleRowSelect:)];
	[self updateLocations];
}

- (void) applicationWillTerminate: (NSNotification *) inNotification
{
}

- (void) updateLocations
{
	[self discoverSimLocations];
	[self.locationOutline reloadData];
}

- (void) discoverSimLocations
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*libraryDirURL = [[fileManager URLsForDirectory: NSLibraryDirectory inDomains: NSUserDomainMask] firstObject];
	
	self.simLocations = [NSMutableArray array];
	
	if (libraryDirURL != nil) {
		libraryDirURL = [libraryDirURL URLByAppendingPathComponent: @"Developer/CoreSimulator/Devices"];
		if (libraryDirURL != nil) {
			NSDirectoryEnumerator	*dirEnum = [fileManager enumeratorAtURL: libraryDirURL includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];
			NSURL					*baseInfoURL;

			while ((baseInfoURL = [dirEnum nextObject])) {
				NSURL			*deviceInfoURL = [baseInfoURL URLByAppendingPathComponent: @"device.plist"];
				
				if (deviceInfoURL != nil && [fileManager fileExistsAtPath: [deviceInfoURL path]]) {
					NSData		*plistData = [NSData dataWithContentsOfURL: deviceInfoURL];
					
					if (plistData != nil) {
						NSDictionary	*plistInfo;
						
						plistInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
						if (plistInfo != nil) {
							NSMutableDictionary		*deviceInfo = [NSMutableDictionary dictionary];
							NSString				*name = plistInfo[@"name"];
							NSString				*runtime = plistInfo[@"runtime"];
							NSRange					runtimeRange;
							
							runtimeRange = [runtime rangeOfString: @"iOS.*" options: NSRegularExpressionSearch];
							if (runtimeRange.location != NSNotFound) {
								NSArray		*versionComponents = [[runtime substringWithRange: runtimeRange] componentsSeparatedByString: @"-"];
								
								deviceInfo[@"path"] = [baseInfoURL path];
								deviceInfo[@"title"] = [NSString stringWithFormat: @"%@: %@ %@.%@", name, versionComponents[0], versionComponents[1], versionComponents[2]];
								[self updateDeviceInfoForApps: deviceInfo];
								[self.simLocations addObject: deviceInfo];
							}
						}
					}
				}
			}
		}
	}
}

- (void) updateDeviceInfoForApps: (NSMutableDictionary *) inDeviceInfo
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*backboardInfoURL = [[NSURL alloc] initFileURLWithPath: inDeviceInfo[@"path"]];
	
	backboardInfoURL = [backboardInfoURL URLByAppendingPathComponent: @"data/Library/BackBoard/applicationState.plist"];
	if (backboardInfoURL != nil && [fileManager fileExistsAtPath: [backboardInfoURL path]]) {
		NSData			*plistData = [NSData dataWithContentsOfURL: backboardInfoURL];
		NSDictionary	*plistInfo;
						
		plistInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
		for (NSString *bundleID in plistInfo) {
			if ([bundleID rangeOfString: @"com.apple" options: NSAnchoredSearch].location == NSNotFound) {
				NSMutableArray			*appPaths = [NSMutableArray array];
				NSDictionary			*appInfo = plistInfo[bundleID][@"compatibilityInfo"];
				
				if (appInfo != nil) {
					NSArray		*pathKeys = @[
									@{ @"title" : @"Bundle Location", @"pathKey" : @"bundlePath" },
									@{ @"title" : @"Sandbox Location", @"pathKey" : @"sandboxPath" } ];
					
					[pathKeys enumerateObjectsUsingBlock: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
						NSString	*appPath = appInfo[inObject[@"pathKey"]];
						
//NSLog(@"test %@ - %@", appPath, [fileManager fileExistsAtPath: appPath] ? @"YES" : @"NO");
						if (appPath != nil && [fileManager fileExistsAtPath: appPath]) {
							[appPaths addObject: @{
								@"title" : inObject[@"title"],
								@"path" : appPath
							}];
						}
					}];

					if ([appPaths count]) {
						NSMutableArray			*deviceApps = inDeviceInfo[@"children"];
						
						if (deviceApps == nil) {
							deviceApps = [NSMutableArray array];
							inDeviceInfo[@"children"] = deviceApps;
						}
						
						[deviceApps addObject: @{
							@"title" : bundleID,
							@"children" : appPaths
						}];
					}
				}
			}
		}
	}
}

#pragma mark - Handlers

- (IBAction) handleRowSelect: (id) inSender
{
	if (inSender == self.locationOutline) {
		id				item = [self.locationOutline itemAtRow: [self.locationOutline clickedRow]];
		
		if (item != nil) {
			if (item[@"path"] != nil) {
				NSURL		*itemPathURL = [[NSURL alloc] initFileURLWithPath: item[@"path"]];

				if (itemPathURL != nil) {
					[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[ itemPathURL ]];
				}
			}
			else {
				if ([self.locationOutline isItemExpanded: item]) {
					[self.locationOutline collapseItem: item];
				}
				else {
					[self.locationOutline expandItem: item];
				}
			}
		}
	}
}

- (IBAction) handleUpdate: (id) inSender
{
	[self updateLocations];
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger) outlineView: (NSOutlineView *) inOutlineView
	numberOfChildrenOfItem: (id) inItem
{
	NSArray		*target = inItem == nil ? self.simLocations : inItem[@"children"];
	
	return [target count];
}

- (id) outlineView: (NSOutlineView *) inOutlineView
	child: (NSInteger) inIndex
	ofItem: (id) inItem
{
	NSArray		*target = inItem == nil ? self.simLocations : inItem[@"children"];

	return [target objectAtIndex: inIndex];
}

- (BOOL) outlineView: (NSOutlineView *) inOutlineView
	isItemExpandable: (id) inItem
{
	NSArray		*target = inItem == nil ? self.simLocations : inItem[@"children"];

	return [target count] ? YES : NO;
}

- (id) outlineView: (NSOutlineView *) inOutlineView
	objectValueForTableColumn: (NSTableColumn *) inTableColumn
	byItem: (id) inItem
{
	return [inItem objectForKey: @"title"];
}


@end
