//
//  PZConnectionItem.m
//  SynoTool
//
//  Created by Piotr on 03/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import "PZConnectionItem.h"
#import "SynoTool-Swift.h"

@interface PZConnectionItem ()

@property BOOL initializedOnce;

@property (weak) IBOutlet NSTextField *connectionWhoLabel;
@property (weak) IBOutlet NSTextField *connectionDescriptionLabel;
@property (weak) IBOutlet NSTextField *connectionTypeLabel;
@property (weak) IBOutlet NSTextField *connectionFromLabel;
@property (weak) IBOutlet PZSettingsButton *kickButton;

@property NSUInteger volumeUsedSizeValue;
@property NSUInteger volumeTotalSizeValue;

@property (copy) PZConnectionItemKickClickBlock kickClickBlock;

@end

@implementation PZConnectionItem

+ (PZConnectionItem *)load:(id)owner
{
    NSArray *objects = [NSArray new];
    
    if ([[NSBundle mainBundle] loadNibNamed:@"PZConnectionItem" owner:owner topLevelObjects:&objects])
    {
        for (id item in objects)
        {
            if ([item isKindOfClass:PZConnectionItem.class])
            {
                PZConnectionItem *view = item;
                
                [view setHidden:YES];
                
                return view;
            }
        }
    }
    
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.initializedOnce = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    //avoid multiple awakeFromNib calls in case of nested archived objects
    if (self.initializedOnce == NO)
    {
        self.initializedOnce = YES;

        [self initializeView];
    }
}

- (void)dealloc
{
    self.kickButton.onClickBlock = nil;
    self.kickClickBlock = nil;
}

- (void)initializeView
{
    [self reset];
}

- (void)reset
{
    self.connectionWhoLabel.placeholderString = @"WHO";
    self.connectionDescriptionLabel.placeholderString = @"DESCRIPTION";
    self.connectionTypeLabel.placeholderString = @"TYPE";
    self.connectionFromLabel.placeholderString = @"FROM";
    
    self.kickButton.isEnabled = NO;

    self.connectionWhoLabel.stringValue = @"";
    self.connectionDescriptionLabel.stringValue = @"";
    self.connectionTypeLabel.stringValue = @"";
    self.connectionFromLabel.stringValue = @"";

    self.connectionWhoLabel.textColor = PZTheme.sectionValueColor;
    self.connectionDescriptionLabel.textColor = PZTheme.sectionTextColor;
    self.connectionTypeLabel.textColor = PZTheme.connectionTypeTextColor;
    self.connectionFromLabel.textColor = PZTheme.connectionFromTextColor;

    //MARK: kicking connection action is disabled, because API does not work
    self.kickButton.hidden = YES;
}

- (NSInteger)tag
{
    return -1;
}

#pragma mark Properties

- (NSString *)connectionWho
{
    return self.connectionWhoLabel.stringValue;
}

- (void)setConnectionWho:(NSString *)connectionWho
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.connectionWhoLabel.stringValue = connectionWho.uppercaseString;
    });
}

- (NSString *)connectionDescription
{
    return self.connectionDescriptionLabel.stringValue;
}

- (void)setConnectionDescription:(NSString *)connectionDescription
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.connectionDescriptionLabel.stringValue = connectionDescription;
    });
}

- (NSString *)connectionType
{
    return self.connectionTypeLabel.stringValue;
}

- (void)setConnectionType:(NSString *)connectionType
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.connectionTypeLabel.stringValue = connectionType;
    });
}

- (NSString *)connectionFrom
{
    return self.connectionFromLabel.stringValue;
}

- (void)setConnectionFrom:(NSString *)connectionFrom
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.connectionFromLabel.stringValue = connectionFrom;
    });
}

- (BOOL)isKickEnabled
{
    return self.kickButton.isEnabled;
}

- (void)setIsKickEnabled:(BOOL)isKickEnabled
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.kickButton.isEnabled = isKickEnabled;
    });
}

#pragma mark Actions

- (PZConnectionItemKickClickBlock)kickClick
{
    return self.kickClickBlock;
}

- (void)setKickClick:(PZConnectionItemKickClickBlock)kickClick
{
    self.kickClickBlock = kickClick;

    __weak typeof(self) weakSelf = self;

    self.kickButton.onClickBlock = ^(id button)
    {
        weakSelf.kickClickBlock(weakSelf);
    };
}

@end
