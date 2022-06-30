//
//  PZConnectionItem.h
//  SynoTool
//
//  Created by Piotr on 03/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PZConnectionItem;

typedef void (^PZConnectionItemKickClickBlock)(PZConnectionItem *connectionItem);

@interface PZConnectionItem : NSView

@property NSString *connectionWho;
@property NSString *connectionDescription;
@property NSString *connectionType;
@property NSString *connectionFrom;

@property BOOL isKickEnabled;

@property PZConnectionItemKickClickBlock kickClick;

+ (PZConnectionItem *)load:(id)owner;

@end
