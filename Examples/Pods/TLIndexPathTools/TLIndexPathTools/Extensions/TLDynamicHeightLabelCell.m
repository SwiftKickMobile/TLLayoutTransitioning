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
    //the dynamic size is calculated by taking the original size and incrementing
    //by the change in the label's size after configuring. Here, we're using the
    //intrinsic size because this project uses Auto Layout and the label's size
    //after calling `sizeToFit` does not match the intrinsic size. I don't completely
    //understand why this is yet, but using the intrinsic size works just fine.
    CGSize labelSize = self.label.intrinsicContentSize;
    CGSize size = self.originalSize;
    size.width += labelSize.width - self.originalLabelSize.width;
    size.height += labelSize.height - self.originalLabelSize.height;
    return size;
}

@end
