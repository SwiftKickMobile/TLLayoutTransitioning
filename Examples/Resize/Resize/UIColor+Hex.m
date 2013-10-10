//
//  UIColor+Hex.m
//  Shuffle
//
//  Created by Tim Moose on 5/30/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexRGB:(unsigned)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
