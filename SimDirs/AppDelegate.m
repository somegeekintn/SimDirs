//
//  AppDelegate.m
//  SimDirs
//
//  Created by Casey Fleser on 9/10/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "AppDelegate.h"

// bundleID (e.g. com.foobar.spacefrenzy ), followed by app version label
#define BUNDLE_VERSION_FORMAT   @"%@ %@"

// market version label (internal version label)
#define APP_VERSION_LABEL      @"%@ (%@)"


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

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
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
								[self updateDeviceInfoForAppsFromLogs: deviceInfo];
								[self.simLocations addObject: deviceInfo];
							}
						}
					}
				}
			}
		}
	}
}

- (void) addPath: (NSString *) inPath
	withTitle: (NSString *) inTitle
	withBundleInfo: (NSMutableDictionary *) inBundleInfo
{
	NSMutableArray		*pathList = inBundleInfo[@"children"];
	NSMutableDictionary	*pathInfo;
	NSInteger			pathIndex;

	if (pathList == nil) {
		pathList = [NSMutableArray array];
		inBundleInfo[@"children"] = pathList;
	}

	pathIndex = [pathList indexOfObjectPassingTest: ^BOOL(id inObject, NSUInteger inIndex, BOOL *outStop) {
		*outStop = [inObject[@"path"] isEqualToString: inPath];
		return *outStop;
	}];
	
	if (pathIndex == NSNotFound) {
		pathInfo = [NSMutableDictionary dictionary];
		pathInfo[@"title"] = inTitle;
		pathInfo[@"path"] = inPath;
		[pathList addObject: pathInfo];
	}
	// we already have this path
}

- (void) addPath: (NSString *) inPath
	withTitle: (NSString *) inTitle
	forBundleID: (NSString *) inBundleID
	withDeviceInfo: (NSMutableDictionary *) inDeviceInfo
{
	NSMutableArray		*bundleList = inDeviceInfo[@"children"];
	NSMutableDictionary	*bundleInfo;
	NSInteger			bundleIndex;

	if (bundleList == nil) {
		bundleList = [NSMutableArray array];
		inDeviceInfo[@"children"] = bundleList;
	}

	bundleIndex = [bundleList indexOfObjectPassingTest: ^BOOL(id inObject, NSUInteger inIndex, BOOL *outStop) {
		*outStop = [inObject[@"title"] isEqualToString: inBundleID];
		return *outStop;
	}];
	if (bundleIndex == NSNotFound) {
		bundleInfo = [NSMutableDictionary dictionary];
		bundleInfo[@"title"] = inBundleID;
		[bundleList addObject: bundleInfo];
	}
	else {
		bundleInfo = [bundleList objectAtIndex: bundleIndex];
	}
	
	[self addPath: inPath withTitle: inTitle withBundleInfo: bundleInfo];
}

- (void) updateDeviceInfoForApps: (NSMutableDictionary *) inDeviceInfo
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*launchMapInfoURL = [[NSURL alloc] initFileURLWithPath: inDeviceInfo[@"path"]];
    
    NSMutableDictionary *versionInfoTable = [[NSMutableDictionary alloc] init];
	
	launchMapInfoURL = [launchMapInfoURL URLByAppendingPathComponent: @"data/Library/MobileInstallation/LastLaunchServicesMap.plist"];
	if (launchMapInfoURL != nil && [fileManager fileExistsAtPath: [launchMapInfoURL path]]) {
		NSData			*plistData = [NSData dataWithContentsOfURL: launchMapInfoURL];
		NSDictionary	*launchInfo;
		NSDictionary	*userInfo;
		
		launchInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
		userInfo = launchInfo[@"User"];
		
		for (NSString *bundleID in userInfo) {
			NSDictionary			*appInfo = userInfo[bundleID];
			
			if (appInfo != nil) {
				NSArray		*pathKeys = @[
								@{ @"title" : @"Bundle Location", @"pathKey" : @"BundleContainer" },
								@{ @"title" : @"Sandbox Location", @"pathKey" : @"Container" } ];
				
				[pathKeys enumerateObjectsUsingBlock: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
					NSString	*appPath = appInfo[inObject[@"pathKey"]];
                    
                    // this section s/b ok. bundle location is always explored prior to sandbox location:
                    NSString * versionInfo = [self getVersionInfo:appPath];
                    if (versionInfo != nil) {
                        versionInfoTable[bundleID] = versionInfo;
                    }
                    else {
                        versionInfo = versionInfoTable[bundleID];
                    }
                    
					
//NSLog(@"test %@ - %@", appPath, [fileManager fileExistsAtPath: appPath] ? @"YES" : @"NO");
					if (appPath != nil && [fileManager fileExistsAtPath: appPath]) {
						[self addPath: appPath withTitle: inObject[@"title"] forBundleID: [NSString stringWithFormat:BUNDLE_VERSION_FORMAT, bundleID, versionInfo] withDeviceInfo: inDeviceInfo];
					}
				}];
			}
		}
	}
}

- (NSString *) getVersionInfo: (NSString *) appPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString *match = @"*.app";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    NSArray *dirList = [fileManager contentsOfDirectoryAtPath:appPath error:nil];
    NSArray *appSubDir = [dirList filteredArrayUsingPredicate:predicate];
    
    if ([appSubDir count] < 1)
        return nil;
    
    NSString * infoPath = [NSString stringWithFormat:@"%@/%@/%@", appPath, appSubDir[0], @"Info.plist"];

    if (! [fileManager fileExistsAtPath:infoPath]) {
        return nil;
    }
    
    NSData *plistData = [fileManager contentsAtPath:infoPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *infoList = (NSDictionary *) [NSPropertyListSerialization
                                               propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format
                                               errorDescription:&errorDesc];
    if (infoList == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:APP_VERSION_LABEL, infoList[@"CFBundleShortVersionString"],
            infoList[@"CFBundleVersion"]];
}



- (void) updateDeviceInfoForAppsFromLogs: (NSMutableDictionary *) inDeviceInfo
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*installLogURL = [[NSURL alloc] initFileURLWithPath: inDeviceInfo[@"path"]];
    
    NSMutableDictionary *versionInfoTable = [[NSMutableDictionary alloc] init];
	
	installLogURL = [installLogURL URLByAppendingPathComponent: @"data/Library/Logs/MobileInstallation/mobile_installation.log.0"];
	if (installLogURL != nil && [fileManager fileExistsAtPath: [installLogURL path]]) {
		NSString		*installLog = [[NSString alloc] initWithContentsOfURL: installLogURL usedEncoding: nil error: nil];
		
		if (installLog != nil) {
			NSRange		logMentionRange;
			
			for (NSString *line in [installLog componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]) {
				logMentionRange = [line rangeOfString: @"Made container live for "];
				if (logMentionRange.location != NSNotFound) {
					NSArray		*installParts = [[line substringFromIndex: logMentionRange.location + logMentionRange.length] componentsSeparatedByString: @" "];
					
					if ([installParts count] == 3) {	// expecting com.foo.bar at UUID
						NSString		*bundleID = [installParts objectAtIndex: 0];

						if ([bundleID rangeOfString: @"com.apple"].location == NSNotFound) {
							NSString		*path = [installParts objectAtIndex: 2];
                            
							
							if (path != nil && [fileManager fileExistsAtPath: path]) {
								NSString		*pathTitle;
                                NSString *versionInfo = nil;
								
								if ([path rangeOfString: @"Data/Application"].location != NSNotFound) {
                                    // in first for-loop iteration, skip the sandbox
                                    continue;
								}
								else if ([path rangeOfString: @"Bundle/Application"].location != NSNotFound) {
									pathTitle = @"Bundle Location";
                                    NSLog(@"bundle id = [%@]", bundleID);
                                    NSLog(@"special path = [%@]", path);
                                    versionInfo = [self getVersionInfo:path];
                                    if (versionInfo != nil) {
                                        versionInfoTable[bundleID] = versionInfo;
                                    }
                                    
                                    NSLog(@"extracted versionInfo = %@", versionInfo);

								}
								else {
									pathTitle = @"???";
								}
								
								[self addPath: path withTitle: pathTitle forBundleID:[NSString stringWithFormat:BUNDLE_VERSION_FORMAT, bundleID, versionInfo] withDeviceInfo: inDeviceInfo];
                            }
						}
                    }
                }
            }

            
            
            for (NSString *line in [installLog componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]) {
                logMentionRange = [line rangeOfString: @"Made container live for "];
                if (logMentionRange.location != NSNotFound) {
                    NSArray		*installParts = [[line substringFromIndex: logMentionRange.location + logMentionRange.length] componentsSeparatedByString: @" "];
                    
                    if ([installParts count] == 3) {	// expecting com.foo.bar at UUID
                        NSString		*bundleID = [installParts objectAtIndex: 0];
                        
                        if ([bundleID rangeOfString: @"com.apple"].location == NSNotFound) {
                            NSString		*path = [installParts objectAtIndex: 2];
                            
                            
                            if (path != nil && [fileManager fileExistsAtPath: path]) {
                                NSString		*pathTitle;
                                NSString *versionInfo = nil;
                                
                                if ([path rangeOfString: @"Data/Application"].location != NSNotFound) {
                                    pathTitle = @"Sandbox Location";
                                    versionInfo = versionInfoTable[bundleID];
                                }
                                else if ([path rangeOfString: @"Bundle/Application"].location != NSNotFound) {
                                    // in second for-loop iteration, skip the bundle location:
                                    continue;
                                }
                                else {
                                    pathTitle = @"???";
                                }
                                
                                [self addPath: path withTitle: pathTitle forBundleID:[NSString stringWithFormat:BUNDLE_VERSION_FORMAT, bundleID, versionInfo] withDeviceInfo: inDeviceInfo];
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
