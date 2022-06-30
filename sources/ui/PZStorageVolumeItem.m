//
//  PZStorageVolumeItem.m
//  SynoTool
//
//  Created by Piotr on 19/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

#import "PZStorageVolumeItem.h"
#import "PZUtils.h"
#import "SynoTool-Swift.h"

@interface PZStorageVolumeItem ()

@property BOOL initializedOnce;

@property (weak) IBOutlet NSTextField *volumeNameLabel;
@property (weak) IBOutlet NSTextField *volumeStatusLabel;
@property (weak) IBOutlet PZProgressBar *volumeSizeBar;
@property (weak) IBOutlet NSTextField *volumeUsedSizeLabel;
@property (weak) IBOutlet NSTextField *volumeTotalSizeLabel;
@property (weak) IBOutlet NSTextField *volumeUsedPercentLabel;

@property NSUInteger volumeUsedSizeValue;
@property NSUInteger volumeTotalSizeValue;

@end

@implementation PZStorageVolumeItem

+ (PZStorageVolumeItem *)load:(id)owner
{
    NSArray *objects = [NSArray new];
    
    if ([[NSBundle mainBundle] loadNibNamed:@"PZStorageVolumeItem" owner:owner topLevelObjects:&objects])
    {
        for (id item in objects)
        {
            if ([item isKindOfClass:PZStorageVolumeItem.class])
            {
                PZStorageVolumeItem *view = item;
                
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

- (void)initializeView
{
    [self reset];
}

- (void)reset
{
    self.volumeUsedSizeValue = 0;
    self.volumeTotalSizeValue = 0;

    self.volumeSizeBar.value = 0;
    self.volumeSizeBar.maxValue = 100;

    self.volumeNameLabel.placeholderString = @"VOLUME NAME";
    self.volumeStatusLabel.placeholderString = @"STATUS";
    self.volumeUsedSizeLabel.placeholderString = @"";
    self.volumeTotalSizeLabel.placeholderString = @"";
    self.volumeUsedPercentLabel.placeholderString = @"%";

    self.volumeNameLabel.stringValue = @"";
    self.volumeStatusLabel.stringValue = @"";
    self.volumeUsedSizeLabel.stringValue = @"";
    self.volumeTotalSizeLabel.stringValue = @"";
    self.volumeUsedPercentLabel.stringValue = @"";
    
    self.volumeNameLabel.textColor = PZTheme.sectionValueColor;
    self.volumeStatusLabel.textColor = PZTheme.sectionTextColor;
    self.volumeUsedSizeLabel.textColor = PZTheme.sectionTextColor;
    self.volumeTotalSizeLabel.textColor = PZTheme.sectionTextColor;
    self.volumeUsedPercentLabel.textColor = PZTheme.sectionValueColor;
    
    self.volumeSizeBar.bkgColor = PZTheme.defaultBarBkgColor;
    self.volumeSizeBar.barColor050 = PZTheme.defaultBar050Color;
    self.volumeSizeBar.barColor075 = PZTheme.defaultBar075Color;
    self.volumeSizeBar.barColor100 = PZTheme.defaultBar100Color;
}

- (NSInteger)tag
{
    return -1;
}

#pragma mark Properties

- (NSString *)volumeName
{
    return self.volumeNameLabel.stringValue;
}

- (void)setVolumeName:(NSString *)volumeName
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.volumeNameLabel.stringValue = volumeName;
    });
}

- (NSString *)volumeStatus
{
    return self.volumeStatusLabel.stringValue;
}

- (void)setVolumeStatus:(NSString *)volumeStatus
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.volumeStatusLabel.stringValue = volumeStatus;
    });
}

- (void)updateUsedPercent
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        double totalSize = self.volumeTotalSizeValue;
        
        if (totalSize == 0)
        {
            weakSelf.volumeUsedPercentLabel.stringValue = @"";
            
            weakSelf.volumeSizeBar.value = 0;
            return;
        }

        NSUInteger percent = ((double)weakSelf.volumeUsedSizeValue / totalSize) * (double)100;
        
        weakSelf.volumeUsedPercentLabel.stringValue = [NSString stringWithFormat:@"%lu%%", (unsigned long)percent];
        
        weakSelf.volumeSizeBar.value = percent;
    });
}

- (NSUInteger)volumeUsedSize
{
    return self.volumeUsedSizeValue;
}

- (void)setVolumeUsedSize:(NSUInteger)volumeUsedSize
{
    self.volumeUsedSizeValue = volumeUsedSize;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.volumeUsedSizeLabel.stringValue = [PZUtils formatBytesCount:self.volumeUsedSizeValue];
    });
}

- (NSUInteger)volumeTotalSize
{
    return self.volumeTotalSizeValue;
}

- (void)setVolumeTotalSize:(NSUInteger)volumeTotalSize
{
    self.volumeTotalSizeValue = volumeTotalSize;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.volumeTotalSizeLabel.stringValue = [PZUtils formatBytesCount:self.volumeTotalSizeValue];
    });
}

@end
