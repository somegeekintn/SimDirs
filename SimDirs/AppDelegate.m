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
@property (nonatomic, weak) IBOutlet NSTableView	*locationTable;
@property (nonatomic, strong) NSMutableArray		*simLocations;

@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
	[self.locationTable setDoubleAction: @selector(handleRowSelect:)];
	[self discoverSimLocations];
	[self.locationTable reloadData];
}

- (void) applicationWillTerminate: (NSNotification *) inNotification
{
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
							NSString		*name = plistInfo[@"name"];
							NSString		*runtime = plistInfo[@"runtime"];
							NSRange			runtimeRange;
							
							runtimeRange = [runtime rangeOfString: @"iOS.*" options: NSRegularExpressionSearch];
							if (runtimeRange.location != NSNotFound) {
								NSArray		*versionComponents = [[runtime substringWithRange: runtimeRange] componentsSeparatedByString: @"-"];
								
								[self.simLocations addObject: @{
									@"path" : [baseInfoURL path],
									@"title" : [NSString stringWithFormat: @"%@: %@ %@.%@", name, versionComponents[0], versionComponents[1], versionComponents[2]],
								}];
							}
						}
					}
				}
			}
		}
	}
}

#pragma mark - Handlers

- (IBAction) handleRowSelect: (id) inSender
{
	if (inSender == self.locationTable) {
		NSInteger		clickedRow = [self.locationTable clickedRow];
		
		if (clickedRow != -1) {
			NSDictionary		*rowInfo = [self.simLocations objectAtIndex: clickedRow];
			NSURL				*devicePathURL = [[NSURL alloc] initFileURLWithPath: rowInfo[@"path"]];
			
			if (devicePathURL != nil) {
				[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[ devicePathURL ]];
			}
		}
	}
}

#pragma mark - NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView: (NSTableView *) inTableView
{
	return [self.simLocations count];
}

- (id) tableView: (NSTableView *) inTableView
	objectValueForTableColumn: (NSTableColumn *) inTableColumn
	row: (NSInteger) inRow
{
	id			cellValue = nil;
	
	if ([inTableColumn.identifier isEqualToString: @"title"]) {
		cellValue = [[self.simLocations objectAtIndex: inRow] objectForKey: @"title"];
	}

	return cellValue;
}

@end
