//
//  AppDelegate.m
//  SimDirs
//
//  Created by Casey Fleser on 9/10/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "AppDelegate.h"
#import "QSSimDeviceInfo.h"
#import "QSSimViewController.h"

@interface AppDelegate ()

@property (nonatomic, weak) IBOutlet NSWindow		*window;

@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) inSender
{
    return YES;
}

@end
