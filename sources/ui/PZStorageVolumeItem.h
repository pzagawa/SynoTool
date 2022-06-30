//
//  PZStorageVolumeItem.h
//  SynoTool
//
//  Created by Piotr on 19/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PZStorageVolumeItem : NSView

@property NSString *volumeName;
@property NSString *volumeStatus;
@property NSUInteger volumeUsedSize;
@property NSUInteger volumeTotalSize;

+ (PZStorageVolumeItem *)load:(id)owner;

- (void)updateUsedPercent;

@end
