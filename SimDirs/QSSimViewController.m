//
//  QSSimViewController.m
//  SimDirs
//
//  Created by Casey Fleser on 10/31/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSSimViewController.h"
#import "QSSimAppInfo.h"
#import "QSSimDeviceInfo.h"


@interface QSSimViewController ()

@property (nonatomic, weak) IBOutlet NSOutlineView	*locationOutline;
@property (nonatomic, weak) IBOutlet NSTabView		*infoTabView;

// Device outlets
@property (nonatomic, weak) IBOutlet NSTextField	*deviceModel;
@property (nonatomic, weak) IBOutlet NSTextField	*deviceVersion;
@property (nonatomic, weak) IBOutlet NSTextField	*deviceUDID;
@property (nonatomic, weak) IBOutlet NSTextField	*devicePath;

// App outlets
@property (nonatomic, weak) IBOutlet NSImageView	*appIcon;
@property (nonatomic, weak) IBOutlet NSTextField	*appName;
@property (nonatomic, weak) IBOutlet NSTextField	*appBundleID;
@property (nonatomic, weak) IBOutlet NSTextField	*appVersion;
@property (nonatomic, weak) IBOutlet NSTextField	*appBundlePath;
@property (nonatomic, weak) IBOutlet NSTextField	*appSandboxPath;
@property (nonatomic, weak) IBOutlet NSButton		*appBundleLocButton;
@property (nonatomic, weak) IBOutlet NSButton		*appSandboxLocButton;

@property (nonatomic, strong) NSArray				*deviceList;
@property (nonatomic, strong) QSSimDeviceInfo		*selectedDevice;
@property (nonatomic, strong) QSSimAppInfo			*selectedApp;
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
	CGFloat		rowHeight = 20.0f;
	
	if ([inItem conformsToProtocol: @protocol(QSOutlineProvider)]) {
		NSImage			*itemImage = [inItem outlineItemImage];
		
		if (itemImage != nil) {
			rowHeight = 24.0f;
		}
	}

	return rowHeight;
}

- (void) outlineViewSelectionDidChange: (NSNotification *) inNotification
{
	NSInteger	row = [self.locationOutline selectedRow];
	BOOL		selectedTab = NO;
	
	self.selectedDevice = nil;
	self.selectedApp = nil;
	
	if (row != -1) {
		id				item = [self.locationOutline itemAtRow: row];
		
		if ([item isKindOfClass: [QSSimDeviceInfo class]]) {
			self.selectedDevice = item;
			[self updateDeviceTabWithSelection];
			
			[self.infoTabView selectTabViewItemWithIdentifier: @"device"];
			selectedTab = YES;
		}
		if ([item isKindOfClass: [QSSimAppInfo class]]) {
			self.selectedApp = item;
			[self updateAppTabWithSelection];
			
			[self.infoTabView selectTabViewItemWithIdentifier: @"app"];
			selectedTab = YES;
		}
	}

	if (!selectedTab) {
		[self.infoTabView selectTabViewItemWithIdentifier: @"empty"];
	}
}

#pragma mark - Updating

- (void) updateDeviceTabWithSelection
{
	self.deviceModel.stringValue = self.selectedDevice.name;
	self.deviceVersion.stringValue = self.selectedDevice.version;
	self.deviceUDID.stringValue = self.selectedDevice.udid;
	self.devicePath.stringValue = [self.selectedDevice.baseURL path];
}

- (void) updateAppTabWithSelection
{
	NSString	*bundlePath = self.selectedApp.bundlePath;
	NSString	*sandboxPath = self.selectedApp.sandboxPath;
	NSString	*appName = self.selectedApp.appName;
	NSString	*fullVersion = self.selectedApp.fullVersion;
	
	if ([[bundlePath lastPathComponent] rangeOfString: @".app"].location != NSNotFound) {
		bundlePath = [bundlePath stringByDeletingLastPathComponent];
	}
	
	self.appIcon.image = self.selectedApp.appIcon;
	self.appBundleID.stringValue = self.selectedApp.bundleID;
	self.appName.stringValue = appName != nil ? appName : self.selectedApp.bundleID;
	self.appVersion.stringValue = fullVersion != nil ? fullVersion : @"unknown version";
	if (bundlePath != nil) {
		self.appBundlePath.stringValue = bundlePath;
		self.appBundleLocButton.enabled = YES;
	}
	else {
		self.appBundlePath.stringValue = @"";
		self.appBundleLocButton.enabled = NO;
	}
	if (sandboxPath != nil) {
		self.appSandboxPath.stringValue = sandboxPath;
		self.appSandboxLocButton.enabled = YES;
	}
	else {
		self.appSandboxPath.stringValue = @"";
		self.appSandboxLocButton.enabled = NO;
	}
}

#pragma mark - Handlers

- (void) openSelectedDeviceLocation: (id) inSender
{
	if (self.selectedDevice != nil) {
		[self.selectedDevice openDeviceLocation];
	}
}

- (void) openSelectedAppBundleLoc: (id) inSender
{
	if (self.selectedApp != nil) {
		[self.selectedApp openBundleLocation];
	}
}

- (void) openSelectedAppSandboxLoc: (id) inSender
{
	if (self.selectedApp != nil) {
		[self.selectedApp openSandboxLocation];
	}
}

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
