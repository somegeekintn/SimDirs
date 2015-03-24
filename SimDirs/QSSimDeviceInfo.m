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
						self.udid = plistInfo[@"UDID"];
						self.version = [NSString stringWithFormat: @"%@.%@", versionComponents[1], versionComponents[2]];
						self.appList = [NSMutableArray array];
						
						[self gatherAppInfoFromLastLaunchMap];
						[self gatherAppInfoFromAppState];
						[self gatherAppInfoFromCaches];
						[self gatherAppInfoFromInstallLogs];
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
	
	return [NSString stringWithFormat: @"%@: %@ %@", self.name, self.version, childDescriptions];
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
	NSURL			*appStateInfoURL = [self.baseURL URLByAppendingPathComponent: @"data/Library/BackBoard/applicationState.plist"];
	
	if (appStateInfoURL != nil && [fileManager fileExistsAtPath: [appStateInfoURL path]]) {
		NSData			*plistData = [NSData dataWithContentsOfURL: appStateInfoURL];
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

// Xcode 6.2 seems to have changed things up for 7.1 apps
- (void) gatherAppInfoFromCaches
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*cacheDirURL = [self.baseURL URLByAppendingPathComponent: @"data/Library/Caches/"];

	if (cacheDirURL != nil) {
		NSArray		*cacheFileURLS = [fileManager contentsOfDirectoryAtURL: cacheDirURL includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants error: nil];
		NSInteger	installInfoIndex;
		
		installInfoIndex = [cacheFileURLS indexOfObjectPassingTest: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
			NSURL	*testURL = inObject;
			BOOL	match = NO;
			
			if ([[testURL path] rangeOfString: @"com.apple.mobile.installation"].location != NSNotFound) {
				match = YES;
			}
			
			*outStop = match;
			return match;
		}];
		
		if (installInfoIndex != NSNotFound) {
			NSURL			*installInfoURL = [cacheFileURLS objectAtIndex: installInfoIndex];
			NSData			*plistData = [NSData dataWithContentsOfURL: installInfoURL];
			NSDictionary	*installInfo;
			NSDictionary	*userInfo;
		
			installInfo = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
			userInfo = installInfo[@"User"];
			if (userInfo != nil) {
				for (NSString *bundleID in [userInfo allKeys]) {
					QSSimAppInfo			*appInfo = [self appInfoWithBundleID: bundleID];

					if (appInfo != nil) {
						[appInfo updateFromCacheInfo: userInfo[bundleID]];
					}
				}
			}
		}
	}
}

// mobile_installation.log.0 is my least favorite, most fragile way to scan for app installations
// try this after everything else
- (void) gatherAppInfoFromInstallLogs
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL			*installLogURL = [self.baseURL URLByAppendingPathComponent: @"data/Library/Logs/MobileInstallation/mobile_installation.log.0"];
	
	if (installLogURL != nil && [fileManager fileExistsAtPath: [installLogURL path]]) {
		NSString		*installLog = [[NSString alloc] initWithContentsOfURL: installLogURL usedEncoding: nil error: nil];

		if (installLog != nil) {
			// check these from most recent to oldest
			for (NSString *line in [[installLog componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] reverseObjectEnumerator]) {
				if ([line rangeOfString: @"com.apple"].location == NSNotFound) {
					NSRange		logHintRange;

					logHintRange = [line rangeOfString: @"makeContainerLiveReplacingContainer"];
					if (logHintRange.location != NSNotFound) {
						[self extractBundleLocationFromLogEntry: line];
					}
					
					logHintRange = [line rangeOfString: @"_refreshUUIDForContainer"];
					if (logHintRange.location != NSNotFound) {
						[self extractSandboxLocationFromLogEntry: line];
					}
				}
			}
		}
	}
}

- (void) extractBundleLocationFromLogEntry: (NSString *) inLine
{
	NSArray		*logComponents = [inLine componentsSeparatedByString: @" "];
	NSString	*bundlePath = [logComponents lastObject];
	
	if (bundlePath != nil) {
		NSInteger	bundleIDIndex = [logComponents count] - 3;
		
		if (bundleIDIndex >= 0) {
			NSString		*bundleID = [logComponents objectAtIndex: bundleIDIndex];
			QSSimAppInfo	*appInfo = [self appInfoWithBundleID: bundleID];
				
			if (appInfo != nil) {
				appInfo.bundlePath = bundlePath;
			}
		}
	}
}

- (void) extractSandboxLocationFromLogEntry: (NSString *) inLine
{
	NSArray		*logComponents = [inLine componentsSeparatedByString: @" "];
	NSString	*sandboxPath = [logComponents lastObject];
	
	if (sandboxPath != nil) {
		NSInteger	bundleIDIndex = [logComponents count] - 5;
		
		if (bundleIDIndex >= 0) {
			NSString		*bundleID = [logComponents objectAtIndex: bundleIDIndex];
			QSSimAppInfo	*appInfo = [self appInfoWithBundleID: bundleID];
				
			if (appInfo != nil) {
				appInfo.sandboxPath = sandboxPath;
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

- (void) openDeviceLocation
{
	if (self.baseURL != nil) {
		[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[ self.baseURL ]];
	}
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

- (NSString *) outlineItemTitle
{
	return self.title;
}

- (NSImage *) outlineItemImage
{
	return nil;
}

- (BOOL) outlineItemPerformAction
{
	[self openDeviceLocation];
	
	return YES;
}

- (BOOL) outlineItemPerformActionForChild: (id) inChild
{
	return NO;
}

#pragma mark - Setters / Getters

- (NSString *) title
{
	return [NSString stringWithFormat: @"%@: %@", self.name, self.version];
}

@end
