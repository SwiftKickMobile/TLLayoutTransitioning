//
//  UITableView+ScrollOptimizer.h
//  TLIndexPathTools
//
//  Created by Tim Moose on 4/17/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TLTableViewScrollOptions) {
    /**
     Include the section headers of the given `indexPaths when in calculating the
     optimal `contentOffset`.
     */
    TLTableViewScrollOptionsIncludeHeaderViews = 1 << 0,
    /**
     Include the section footers of the given `indexPaths when in calculating the
     optimal `contentOffset`.
     */
    TLTableViewScrollOptionsIncludeFooterViews = 1 << 1,
};

@interface UITableView (ScrollOptimizer)

/**
 Optimize the scroll postion to ensure as many rows of the given section as
 possible are visible.
 */
- (void)optimizeScrollPositionForSection:(NSInteger)section
                                 options:(TLTableViewScrollOptions)options
                                animated:(BOOL)animated;

/**
 Optimize the scroll postion to ensure as many rows of the given index
 paths are visible.
 */
- (void)optimizeScrollPositionForIndexPaths:(NSArray *)indexPaths
                                    options:(TLTableViewScrollOptions)options
                                   animated:(BOOL)animated;

@end
