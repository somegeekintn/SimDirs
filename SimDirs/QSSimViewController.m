//
//  QSSimViewController.m
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSSimViewController.h"
#import "QSSimDeviceInfo.h"


@interface QSSimViewController ()

@property (nonatomic, weak) IBOutlet NSOutlineView	*locationOutline;
@property (nonatomic, strong) NSArray				*deviceList;

@end


@implementation QSSimViewController

- (void) awakeFromNib
{
	[self reloadOutine];

	[self.locationOutline setTarget: self];
	[self.locationOutline setDoubleAction: @selector(handleRowSelect:)];
}

- (void) reloadOutine
{
	NSArray		*deviceList = [QSSimDeviceInfo gatherDeviceLocations];
	
	self.deviceList = [deviceList sortedArrayUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"title" ascending:YES ]]];
	[self.locationOutline reloadData];
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger) outlineView: (NSOutlineView *) inOutlineView
	numberOfChildrenOfItem: (id) inItem
{
	NSInteger	childCount = 0;
	
	if (inItem == nil) {
		childCount = [self.deviceList count];
	}
	else {
		if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
			childCount = [inItem outlineChildCount];
		}
	}
	
	return childCount;
}

- (id) outlineView: (NSOutlineView *) inOutlineView
	child: (NSInteger) inIndex
	ofItem: (id) inItem
{
	id		child = nil;

	if (inItem == nil) {
		child = [self.deviceList objectAtIndex: inIndex];
	}
	else {
		if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
			child = [inItem outlineChildAtIndex: inIndex];
		}
	}

	return child;
}

- (BOOL) outlineView: (NSOutlineView *) inOutlineView
	isItemExpandable: (id) inItem
{
	BOOL		expandable = NO;

	if (inItem == nil) {
		expandable = [self.deviceList count] ? YES : NO;
	}
	else {
		if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
			expandable = [inItem outlineItemIsExpanable];
		}
	}

	return expandable;
}

- (id) outlineView: (NSOutlineView *) inOutlineView
	objectValueForTableColumn: (NSTableColumn *) inTableColumn
	byItem: (id) inItem
{
	if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
		inItem = [inItem outlineItemValueForColumn: inTableColumn];
	}
	else if (![inTableColumn.identifier isEqualToString: @"title"]) {
		inItem = nil;
	}
	
	return inItem;
}

#pragma mark - Handlers

- (void) handleRowSelect: (id) inSender
{
	if (inSender == self.locationOutline) {
		id				item = [self.locationOutline itemAtRow: [self.locationOutline clickedRow]];
		BOOL			handled = NO;
		
		if (item != nil) {
			if ([item conformsToProtocol: @protocol(QSOutlineProvider)]) {
				handled = [item outlineItemPerformAction];
			}
			else {
				id	parentItem = [self.locationOutline parentForItem: item];
				
				if ([parentItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
					handled = [parentItem outlineItemPerformActionForChild: item];
				}
			}
			
			if (!handled) {
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
	[self reloadOutine];
}

@end
