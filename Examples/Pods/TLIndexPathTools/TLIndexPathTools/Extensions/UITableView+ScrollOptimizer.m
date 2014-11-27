//
//  UITableView+ScrollOptimizer.m
//  TLIndexPathTools
//
//  Created by Tim Moose on 4/17/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import "UITableView+ScrollOptimizer.h"

@implementation UITableView (ScrollOptimizer)

- (void)optimizeScrollPositionForSection:(NSInteger)section options:(TLTableViewScrollOptions)options animated:(BOOL)animated
{
    [self optimizeScrollPositionForSection:section options:options topInset:0 animated:animated];
}

- (void)optimizeScrollPositionForSection:(NSInteger)section options:(TLTableViewScrollOptions)options topInset:(CGFloat)topInset animated:(BOOL)animated
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.dataSource tableView:self numberOfRowsInSection:section] - 1 inSection:section];
    [self optimizeScrollPositionForIndexPaths:@[firstIndexPath, lastIndexPath] options:options topInset:topInset animated:animated];
}

- (void)optimizeScrollPositionForIndexPaths:(NSArray *)indexPaths options:(TLTableViewScrollOptions)options animated:(BOOL)animated
{
    [self optimizeScrollPositionForIndexPaths:indexPaths options:options topInset:0 animated:animated];
}

- (void)optimizeScrollPositionForIndexPaths:(NSArray *)indexPaths options:(TLTableViewScrollOptions)options topInset:(CGFloat)topInset animated:(BOOL)animated
{
    [self layoutIfNeeded];
    CGRect rect = CGRectNull;
    NSInteger section = -1;
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.section != section) {
            section = indexPath.section;
            if (options & TLTableViewScrollOptionsIncludeHeaderViews) {
                CGRect headerFrame = [self rectForHeaderInSection:section];
                rect = CGRectUnion(rect, headerFrame);
            }
            if (options & TLTableViewScrollOptionsIncludeFooterViews) {
                CGRect footerFrame = [self rectForFooterInSection:section];
                rect = CGRectUnion(rect, footerFrame);
            }
        }
        CGRect indexPathFrame = [self rectForRowAtIndexPath:indexPath];
        rect = CGRectUnion(rect, indexPathFrame);
    }
    CGFloat maxY = CGRectGetMaxY(rect);
    CGSize contentSize = self.contentSize;
    if (maxY > contentSize.height) {
        // the situation where the max calculated Y value of the given index paths
        // is greater than the content size occurs during batch updates when the
        // table hasn't yet recalculated content size. Modifying the content size
        // allows `scrollRectToVisible` to work and the value gets overridden later
        // by the table with the official value.
        contentSize.height = maxY;
        self.contentSize = contentSize;
    }
    // truncate the height of the positioning rect if it's greater than the
    // table view's height because we want to ensure the top cells are visible.
    rect.size.height = MIN(self.bounds.size.height - topInset, rect.size.height);
    [self scrollRectToVisible:rect animated:animated];
}

@end
