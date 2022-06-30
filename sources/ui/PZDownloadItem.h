//
//  PZDownloadItem.h
//  SynoTool
//
//  Created by Piotr on 09/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PZDownloadItem;

typedef void (^PZDownloadItemResumeClickBlock)(PZDownloadItem *downloadItem);
typedef void (^PZDownloadItemDeleteClickBlock)(PZDownloadItem *downloadItem);

@interface PZDownloadItem : NSView

@property NSString *itemTitle;
@property NSString *itemStatus;
@property NSString *itemType;
@property NSUInteger fileSize;
@property NSUInteger fileSizeCompleted;
@property NSColor *barColor;
@property NSColor *statusColor;

@property NSUInteger buttonState;

@property BOOL isResumeButtonEnabled;
@property BOOL isDeleteButtonEnabled;

@property PZDownloadItemResumeClickBlock resumeClick;
@property PZDownloadItemDeleteClickBlock deleteClick;

+ (PZDownloadItem *)load:(id)owner;

- (void)updateCompletedPercent;

@end
