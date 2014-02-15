//
//  TLCollapsibleHeaderView.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLCollapsibleHeaderView.h"

@implementation TLCollapsibleHeaderView

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    [self setNeedsLayout];
}

- (void)setIconView:(UIImageView *)iconView
{
    if (_iconView != iconView) {
        [_iconView removeFromSuperview];
        [self addSubview:iconView];
        _iconView = iconView;
        [self setNeedsLayout];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (_backgroundView != backgroundView) {
        [_backgroundView removeFromSuperview];
        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
        _backgroundView = backgroundView;
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    if (self.iconView) {
        CGRect iconFrame = self.iconView.bounds;
        iconFrame.origin.x = contentFrame.origin.x;
        self.iconView.frame = iconFrame;
        CGPoint iconCenter = self.iconView.center;
        iconCenter.y = contentFrame.origin.y + contentFrame.size.height/2.0;
        self.iconView.center = iconCenter;
        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.origin.x = iconFrame.origin.x + iconFrame.size.width + 10;
        titleFrame.size.width = MAX(0, contentFrame.origin.x + contentFrame.size.width - titleFrame.origin.x);
        self.titleLabel.frame = titleFrame;
    } else {
        self.titleLabel.frame = contentFrame;
    }
    CGRect backgroundFrame = self.bounds;
    if (self.separatorColor) {
        backgroundFrame.size.height--;
    }
    self.backgroundView.frame = backgroundFrame;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.separatorColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, 0, self.bounds.size.height - 0.5);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - 0.5);
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextStrokePath(context);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:_titleLabel];
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        self.contentInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andSection:(NSInteger)section
{
    if (self = [self initWithFrame:frame]) {
        _section = section;
    }
    return self;
}

@end
