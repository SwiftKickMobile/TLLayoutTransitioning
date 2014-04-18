//
//  UITableViewController+ScrollOptimizer.h
//  
//
//  Created by Tim Moose on 5/28/13.
//
//

#import <UIKit/UIKit.h>
#import "TLIndexPathDataModel.h"

@interface UITableViewController (ScrollOptimizer)

/**
 Deprectated. Use the `UITableView+ScrollOptimizer` instead
 */
- (void)optimizeScrollPositionForSection:(NSInteger)section headerView:(UIView *)headerView dataModel:(TLIndexPathDataModel *)dataModel animated:(BOOL)animated DEPRECATED_ATTRIBUTE;

@end
