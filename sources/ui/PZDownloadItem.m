//
//  PZDownloadItem.m
//  SynoTool
//
//  Created by Piotr on 09/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import "PZDownloadItem.h"
#import "PZUtils.h"
#import "SynoTool-Swift.h"

@interface PZDownloadItem ()

@property BOOL initializedOnce;

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet PZProgressBar *downloadCompletedBar;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *typeLabel;
@property (weak) IBOutlet NSTextField *fileSizeCompletedLabel;
@property (weak) IBOutlet NSTextField *fileSizeLabel;

@property (weak) IBOutlet PZDownloadResumeButton *resumeButton;
@property (weak) IBOutlet PZDownloadDeleteButton *deleteButton;

@property NSUInteger fileSizeValue;
@property NSUInteger fileSizeCompletedValue;

@property (copy) PZDownloadItemResumeClickBlock resumeClickBlock;
@property (copy) PZDownloadItemDeleteClickBlock deleteClickBlock;

@end

@implementation PZDownloadItem

+ (PZDownloadItem *)load:(id)owner
{
    NSArray *objects = [NSArray new];
    
    if ([[NSBundle mainBundle] loadNibNamed:@"PZDownloadItem" owner:owner topLevelObjects:&objects])
    {
        for (id item in objects)
        {
            if ([item isKindOfClass:PZDownloadItem.class])
            {
                PZDownloadItem *view = item;
                
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
}

- (void)initializeView
{
    [self reset];
}

- (void)reset
{
    NSColor *defaultStatusColor = PZTheme.valueProgressTagColor;

    self.downloadCompletedBar.bkgColor = PZTheme.defaultBarBkgColor;

    self.downloadCompletedBar.barColor050 = defaultStatusColor;
    self.downloadCompletedBar.barColor075 = defaultStatusColor;
    self.downloadCompletedBar.barColor100 = defaultStatusColor;

    self.statusLabel.textColor = defaultStatusColor;
    self.fileSizeCompletedLabel.textColor = defaultStatusColor;
    
    self.titleLabel.stringValue = @"";
    self.statusLabel.stringValue = @"";
    self.typeLabel.stringValue = @"";
    self.fileSizeCompletedLabel.stringValue = @"";
    self.fileSizeLabel.stringValue = @"";

    self.fileSizeValue = 0;
    self.fileSizeCompletedValue = 0;
    
    self.downloadCompletedBar.value = 0;
    self.downloadCompletedBar.maxValue = 100;

    self.resumeButton.isInteractionEnabled = YES;
    self.deleteButton.isInteractionEnabled = YES;
    
    self.resumeButton.defaultBackgroundColor = PZTheme.buttonBackgroundColor;
    self.resumeButton.defaultSymbolColor = PZTheme.buttonSymbolColor;
    self.resumeButton.disabledSymbolColor = PZTheme.buttonDisabledSymbolColor;

    self.deleteButton.defaultBackgroundColor = PZTheme.buttonBackgroundColor;
    self.deleteButton.defaultSymbolColor = PZTheme.buttonSymbolColor;
    self.deleteButton.disabledSymbolColor = PZTheme.buttonDisabledSymbolColor;

    self.typeLabel.textColor = PZTheme.sectionTextColor;
    self.titleLabel.textColor = PZTheme.sectionValueColor;
    self.fileSizeLabel.textColor = PZTheme.sectionTextColor;

}

- (NSInteger)tag
{
    return -1;
}

#pragma mark Properties

#pragma mark Properties

- (NSString *)itemTitle
{
    return self.titleLabel.stringValue;
}

- (void)setItemTitle:(NSString *)itemTitle
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.titleLabel.stringValue = itemTitle;
    });
}

- (NSString *)itemStatus
{
    return self.statusLabel.stringValue;
}

- (void)setItemStatus:(NSString *)itemStatus
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.statusLabel.stringValue = itemStatus.uppercaseString;
    });
}

- (NSString *)itemType
{
    return self.typeLabel.stringValue;
}

- (void)setItemType:(NSString *)itemType
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.typeLabel.stringValue = itemType.uppercaseString;
    });
}

- (NSUInteger)fileSize
{
    return self.fileSizeValue;
}

- (void)setFileSize:(NSUInteger)fileSize
{
    self.fileSizeValue = fileSize;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.fileSizeLabel.stringValue = [PZUtils formatBytesCount:self.fileSizeValue];
    });
}

- (NSUInteger)fileSizeCompleted
{
    return self.fileSizeCompletedValue;
}

- (void)setFileSizeCompleted:(NSUInteger)fileSizeCompleted
{
    self.fileSizeCompletedValue = fileSizeCompleted;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.fileSizeCompletedLabel.stringValue = [PZUtils formatBytesCount:self.fileSizeCompletedValue];
    });
}

- (void)updateCompletedPercent
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        double fileSize = self.fileSize;

        if (fileSize == 0)
        {
            weakSelf.downloadCompletedBar.value = 0;
            return;
        }

        NSUInteger percent = ((double)weakSelf.fileSizeCompleted / fileSize) * (double)100;

        weakSelf.downloadCompletedBar.value = percent;
    });
}

- (NSColor *)barColor
{
    return self.downloadCompletedBar.barColor100;
}

- (void)setBarColor:(NSColor *)barColor
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.downloadCompletedBar.barColor050 = barColor;
        weakSelf.downloadCompletedBar.barColor075 = barColor;
        weakSelf.downloadCompletedBar.barColor100 = barColor;
    });
}

- (NSColor *)statusColor
{
    return self.statusLabel.textColor;
}

- (void)setStatusColor:(NSColor *)statusColor
{
    NSColor *color = PZTheme.isDarkMode ? [statusColor shadowWithLevel:0.15] : [statusColor shadowWithLevel:0.45];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.statusLabel.textColor = color;
        weakSelf.fileSizeCompletedLabel.textColor = color;
    });
}

- (NSUInteger)buttonState
{
    return self.resumeButton.buttonStateRawValue;
}

- (void)setButtonState:(NSUInteger)buttonState
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.resumeButton.buttonStateRawValue = buttonState;
    });
}

- (BOOL)isResumeButtonEnabled
{
    return self.resumeButton.isInteractionEnabled;
}

- (void)setIsResumeButtonEnabled:(BOOL)isResumeButtonEnabled
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.resumeButton.isInteractionEnabled = isResumeButtonEnabled;
    });
}

- (BOOL)isDeleteButtonEnabled
{
    return self.deleteButton.isInteractionEnabled;
}

- (void)setIsDeleteButtonEnabled:(BOOL)isDeleteButtonEnabled
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.deleteButton.isInteractionEnabled = isDeleteButtonEnabled;
    });
}

#pragma mark Actions

- (PZDownloadItemResumeClickBlock)resumeClick
{
    return self.resumeClickBlock;
}

- (void)setResumeClick:(PZDownloadItemResumeClickBlock)resumeClick
{
    self.resumeClickBlock = resumeClick;
    
    __weak typeof(self) weakSelf = self;
    
    self.resumeButton.onClickBlock = ^(id button)
    {
        weakSelf.resumeClickBlock(weakSelf);
    };
}

- (PZDownloadItemDeleteClickBlock)deleteClick
{
    return self.deleteClickBlock;
}

- (void)setDeleteClick:(PZDownloadItemDeleteClickBlock)deleteClick
{
    self.deleteClickBlock = deleteClick;
    
    __weak typeof(self) weakSelf = self;
    
    self.deleteButton.onClickBlock = ^(id button)
    {
        weakSelf.deleteClickBlock(weakSelf);
    };
}

@end
