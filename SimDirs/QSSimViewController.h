//
//  QSSimViewController.h
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QSOutlineProvider <NSObject>

- (NSInteger)			outlineChildCount;
- (id)					outlineChildAtIndex: (NSInteger) inIndex;
- (BOOL)				outlineItemIsExpanable;
- (NSString *)			outlineItemTitle;
- (NSImage *)			outlineItemImage;

- (BOOL)				outlineItemPerformAction;
- (BOOL)				outlineItemPerformActionForChild: (id) inChild;

@end

@interface QSSimViewController : NSObject

@end
