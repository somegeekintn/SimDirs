//
//  QSSimDeviceInfo.m
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSSimDeviceInfo.h"
#import "QSSimAppInfo.h"


@interface QSSimDeviceInfo ()

@property (nonatomic, strong) NSMutableArray	*appList;

@end


@implementation QSSimDeviceInfo

+ (NSArray *) gatherDeviceLocations
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*libraryDirURL = [[fileManager URLsForDirectory: NSLibraryDirectory inDomains: NSUserDomainMask] firstObject];
	NSMutableArray	*deviceList = [NSMutableArray array];
	
	if (libraryDirURL != nil) {
		libraryDirURL = [libraryDirURL URLByAppendingPathComponent: @"Developer/CoreSimulator/Devices"];
		if (libraryDirURL != nil) {
			NSDirectoryEnumerator	*dirEnum = [fileManager enumeratorAtURL: libraryDirURL includingPropertiesForKeys: nil
													options: NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];
			NSURL					*baseInfoURL;
			QSSimDeviceInfo			*deviceInfo;
			
			while ((baseInfoURL = [dirEnum nextObject])) {
				deviceInfo = [[QSSimDeviceInfo alloc] initWithURL: baseInfoURL];
				if (deviceInfo != nil) {
					[deviceList addObject: deviceInfo];
				}
			}
		}
	}

	return deviceList;
}

- (id) initWithURL: (NSURL *) inDeviceURL
{
	if ((self = [super init]) != nil) {
		NSURL		*deviceInfoURL = [inDeviceURL URLByAppendingPathComponent: @"device.plist"];
		BOOL		initOK = NO;
		
		self.baseURL = inDeviceURL;
		if (deviceInfoURL != nil && [[NSFileManager defaultManager] fileExistsAtPath: [deviceInfoURL path]]) {
			NSData		*plistData = [NSData dataWithContentsOfURL: deviceInfoURL];

			if (plistData != nil) {
				NSDictionary	*plistInfo;
				
				plistInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
				if (plistInfo != nil) {
					NSString				*runtime = plistInfo[@"runtime"];
					NSRange					runtimeRange;
					
					runtimeRange = [runtime rangeOfString: @"iOS.*" options: NSRegularExpressionSearch];
					if (runtimeRange.location != NSNotFound) {
						NSArray		*versionComponents = [[runtime substringWithRange: runtimeRange] componentsSeparatedByString: @"-"];
						
						self.name = plistInfo[@"name"];
						self.model = versionComponents[0];
						self.version = [NSString stringWithFormat: @"%@.%@", versionComponents[1], versionComponents[2]];
						self.appList = [NSMutableArray array];
						
						[self gatherAppInfoFromLastLaunchMap];
						[self gatherAppInfoFromAppState];
						[self cleanupAndRefineAppList];
						
						initOK = YES;
					}
				}
			}
		}
		
		if (!initOK) {
			self = nil;
		}
	}
	
	return self;
}

- (NSString *) description
{
	NSMutableArray	*childDescriptions = [NSMutableArray array];
	
	for (QSSimAppInfo *appInfo in self.appList) {
		[childDescriptions addObject: [appInfo description]];
	}
	
	return [NSString stringWithFormat: @"%@: %@ %@ %@", self.name, self.model, self.version, childDescriptions];
}

// LastLaunchServicesMap.plist seems to be the most reliable location to gather app info
- (void) gatherAppInfoFromLastLaunchMap
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*launchMapInfoURL = [self.baseURL URLByAppendingPathComponent: @"data/Library/MobileInstallation/LastLaunchServicesMap.plist"];
	
	if (launchMapInfoURL != nil && [fileManager fileExistsAtPath: [launchMapInfoURL path]]) {
		NSData			*plistData = [NSData dataWithContentsOfURL: launchMapInfoURL];
		NSDictionary	*launchInfo;
		NSDictionary	*userInfo;
		
		launchInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
		userInfo = launchInfo[@"User"];
		
		for (NSString *bundleID in userInfo) {
			QSSimAppInfo			*appInfo = [self appInfoWithBundleID: bundleID];
			
			if (appInfo != nil) {
				[appInfo updateFromLastLaunchMapInfo: userInfo[bundleID]];
			}
		}
	}
}

// applicationState.plist sometimes has info that LastLaunchServicesMap.plist doesn't
- (void) gatherAppInfoFromAppState
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*apStateInfoURL = [self.baseURL URLByAppendingPathComponent: @"data/Library/BackBoard/applicationState.plist"];
	
	if (apStateInfoURL != nil && [fileManager fileExistsAtPath: [apStateInfoURL path]]) {
		NSData			*plistData = [NSData dataWithContentsOfURL: apStateInfoURL];
		NSDictionary	*stateInfo;
		
		stateInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
		
		for (NSString *bundleID in stateInfo) {
			if ([bundleID rangeOfString: @"com.apple"].location == NSNotFound) {
				QSSimAppInfo			*appInfo = [self appInfoWithBundleID: bundleID];
				
				if (appInfo != nil) {
					[appInfo updateFromAppStateInfo: stateInfo[bundleID]];
				}
			}
		}
	}
}

- (void) cleanupAndRefineAppList
{
	NSMutableArray		*mysteryApps = [NSMutableArray array];
	
	for (QSSimAppInfo *appInfo in self.appList) {
		if (!appInfo.hasValidPaths) {
			[mysteryApps addObject: appInfo];
		}
	}
	
	[self.appList removeObjectsInArray: mysteryApps];
	[self.appList sortUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"title" ascending:YES ]]];

	for (QSSimAppInfo *appInfo in self.appList) {
		[appInfo refinePaths];
	}
}

// Used to also scan installation logs for clues but uncertain how useful this is.
// Leaving it here in case I decide to put it back

#if 0
- (void) updateDeviceInfoForAppsFromLogs: (NSMutableDictionary *) inDeviceInfo
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*installLogURL = [[NSURL alloc] initFileURLWithPath: inDeviceInfo[@"path"]];
	
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
								
								if ([path rangeOfString: @"Data/Application"].location != NSNotFound) {
									pathTitle = @"Sandbox Location";
								}
								else if ([path rangeOfString: @"Bundle/Application"].location != NSNotFound) {
									pathTitle = @"Bundle Location";
								}
								else {
									pathTitle = @"???";
								}
								
								[self addPath: path withTitle: pathTitle forBundleID: bundleID withDeviceInfo: inDeviceInfo];
							}
						}
					}
				}
			}
		}
	}
}
#endif

- (QSSimAppInfo *) appInfoWithBundleID: (NSString *) inBundleID
{
	QSSimAppInfo	*appInfo = nil;
	NSInteger		appIndex;
	
	appIndex = [self.appList indexOfObjectPassingTest: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
		QSSimAppInfo		*appInfo = inObject;
		
		*outStop = [appInfo.bundleID isEqualToString: inBundleID];

		return *outStop;
	}];
	
	if (appIndex == NSNotFound) {
		appInfo = [[QSSimAppInfo alloc] initWithBundleID: inBundleID];
		[self.appList addObject: appInfo];
	}
	else {
		appInfo = [self.appList objectAtIndex: appIndex];
	}
	
	return appInfo;
}

#pragma mark - QSOutlineProvider

- (NSInteger) outlineChildCount
{
	return [self.appList count];
}

- (id) outlineChildAtIndex: (NSInteger) inIndex
{
	return [self.appList objectAtIndex: inIndex];
}

- (BOOL) outlineItemIsExpanable
{
	return [self.appList count] ? YES : NO;
}

- (NSString *) outlineItemValueForColumn: (NSTableColumn *) inTableColumn
{
	return [inTableColumn.identifier isEqualToString: @"title"] ? self.title : nil;
}

- (BOOL) outlineItemPerformAction
{
	if (self.baseURL != nil) {
		[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[ self.baseURL ]];
	}
	
	return YES;
}

- (BOOL) outlineItemPerformActionForChild: (id) inChild
{
	return NO;
}

#pragma mark - Setters / Getters

- (NSString *) title
{
	return [NSString stringWithFormat: @"%@: %@ %@", self.name, self.model, self.version];
}

@end
