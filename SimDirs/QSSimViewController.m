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
@property (nonatomic, assign) BOOL					didAwake;

@end


@implementation QSSimViewController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	if (!self.didAwake) {
		[self reloadOutine];

		[self.locationOutline setTarget: self];
		[self.locationOutline setDoubleAction: @selector(handleRowSelect:)];
		self.didAwake = YES;
	}
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

#pragma mark - NSOutlineViewDelegate

- (NSView *) outlineView: (NSOutlineView *) inOutlineView
	viewForTableColumn: (NSTableColumn *) inTableColumn
	item: (id) inItem
{
	NSTableCellView		*cellView = nil;
	
	if ([inTableColumn.identifier isEqualToString: @"title"]) {
		NSString		*itemTitle = inItem;
		NSImage			*itemImage = nil;

		cellView = [inOutlineView makeViewWithIdentifier: @"ItemCell" owner: self];
	
		if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
			itemTitle = [inItem outlineItemTitle];
			itemImage = [inItem outlineItemImage];
		}

		cellView = [inOutlineView makeViewWithIdentifier: itemImage != nil ? @"ImageCell" : @"TextCell" owner: self];
		cellView.textField.stringValue = itemTitle;
		cellView.imageView.image = itemImage;
	}
	
	return cellView;
}

- (CGFloat) outlineView: (NSOutlineView *) inOutlineView
	heightOfRowByItem: (id) inItem
{
	CGFloat		rowHeight = 17.0f;
	
	if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
		NSImage			*itemImage = [inItem outlineItemImage];
		
		if (itemImage != nil) {
			rowHeight = 24.0f;
		}
	}

	return rowHeight;
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
