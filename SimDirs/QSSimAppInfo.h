//
//  QSSimAppInfo.h
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSSimViewController.h"


@interface QSSimAppInfo : NSObject <QSOutlineProvider>

- (id)			initWithBundleID: (NSString *) inBundleID;

- (void)		updateFromLastLaunchMapInfo: (NSDictionary *) inMapInfo;
- (void)		updateFromAppStateInfo: (NSDictionary *) inStateInfo;
- (void)		refinePaths;

@property (nonatomic, strong) NSString		*bundleID;
@property (nonatomic, strong) NSString		*appName;
@property (nonatomic, strong) NSString		*appShortVersion;
@property (nonatomic, strong) NSString		*appVersion;
@property (nonatomic, strong) NSImage		*appIcon;

@property (nonatomic, strong) NSString		*bundlePath;
@property (nonatomic, strong) NSString		*sandBoxPath;
@property (nonatomic, readonly) NSString	*title;
@property (nonatomic, readonly) BOOL		hasValidPaths;

@end
