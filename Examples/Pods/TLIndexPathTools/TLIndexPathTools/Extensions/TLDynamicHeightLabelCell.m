//
//  TLDynamicHeightLabelCell.m
//  Dynamic Height Label Cell
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "TLDynamicHeightLabelCell.h"

@interface TLDynamicHeightLabelCell ()
@property (nonatomic) CGSize originalSize;
@property (nonatomic) CGSize originalLabelSize;
@end

@implementation TLDynamicHeightLabelCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self layoutIfNeeded];
    self.originalSize = self.bounds.size;
    self.originalLabelSize = self.label.bounds.size;
}

- (void)configureWithText:(NSString *)text
{
    self.label.text = text;
    [self.label sizeToFit];
}

#pragma mark - TLDynamicSizeView

- (CGSize)sizeWithData:(id)data
{
    [self configureWithText:data];
    CGSize labelSize = self.label.intrinsicContentSize;
    CGSize size = self.originalSize;
    size.width += labelSize.width - self.originalLabelSize.width;
    size.height += labelSize.height - self.originalLabelSize.height;
    return size;
}

@end
