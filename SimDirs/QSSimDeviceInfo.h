//
//  QSSimDeviceInfo.h
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSSimViewController.h"

@interface QSSimDeviceInfo : NSObject <QSOutlineProvider>

+ (NSArray *)		gatherDeviceLocations;

@property (nonatomic, strong) NSURL			*baseURL;
@property (nonatomic, strong) NSString		*name;
@property (nonatomic, strong) NSString		*model;
@property (nonatomic, strong) NSString		*version;
@property (nonatomic, readonly) NSString	*title;

@end
