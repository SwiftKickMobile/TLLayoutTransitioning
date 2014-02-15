//
//  UITableViewController+ScrollOptimizer.m
//  
//
//  Created by Tim Moose on 5/28/13.
//
//

#import "UITableViewController+ScrollOptimizer.h"

@implementation UITableViewController (ScrollOptimizer)

- (void)optimizeScrollPositionForSection:(NSInteger)section headerView:(UIView *)headerView dataModel:(TLIndexPathDataModel *)dataModel animated:(BOOL)animated
{
    // TODO Why is headerViewForSection: returning nil??? Shouldn't need to pass it in
    //    UIView *headerView = [self.tableView headerViewForSection:section];
    //    if (!headerView) {
    //        return;
    //    }
    CGFloat sectionTop = headerView.frame.origin.y - self.tableView.contentOffset.y;
    if (sectionTop > 0) {
        
        // If top of section is visible, see if we can scroll up to expose more rows in the section
        
        // Compute how much space visible below the top of the section so we can calculate
        // what parts of the section will not be visible
        CGFloat visibleSpaceBelowSectionTop = self.tableView.bounds.size.height - sectionTop;
        
        // Start calculating how much space can be made visible before the section
        // top scrolls out of view above
        CGFloat offsetBelowTopToMakeVisible = headerView.bounds.size.height;
        
        // Calculate how much of the header is not visible
        CGFloat spaceNotVisible = offsetBelowTopToMakeVisible - visibleSpaceBelowSectionTop;
        
        // If there is not enough room to make the header visible, scroll the header to the top
        if (spaceNotVisible > sectionTop) {
            CGFloat locationToMakeVisible = headerView.frame.origin.y + visibleSpaceBelowSectionTop + sectionTop;
            [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
            return;
        }
        
        // Iterate over rows to find out how many can be made visible
        id<NSFetchedResultsSectionInfo>sectionInfo = dataModel.sections[section];
        for (id item in sectionInfo.objects) {
            NSIndexPath *indexPath = [dataModel indexPathForItem:item];
            offsetBelowTopToMakeVisible += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            spaceNotVisible = offsetBelowTopToMakeVisible - visibleSpaceBelowSectionTop;
            // If we run out of space to display all rows, scroll the header to the top
            if (spaceNotVisible > sectionTop) {
                CGSize contentSize = self.tableView.contentSize;
                contentSize.height = 1000;
                self.tableView.contentSize = contentSize;
                CGFloat locationToMakeVisible = headerView.frame.origin.y + visibleSpaceBelowSectionTop + sectionTop;
                [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
                return;
            }
        }
        
        // The entire section can be displayed, so scroll as much as needed
        if (spaceNotVisible > 0) {
            CGFloat locationToMakeVisible = headerView.frame.origin.y + offsetBelowTopToMakeVisible;
            [self forceTableScrollBasedOnExpectedSize:locationToMakeVisible animated:animated];
            return;
        }
        
    } else {
        [self.tableView scrollRectToVisible:headerView.frame animated:animated];
    }
}

/*
 Force table to scroll to the specified location even if it is beyond the current
 content area. Use this to scroll to a future location during animiated table updates
 with the assumption that the location will be valid after the updates.
 */
- (void)forceTableScrollBasedOnExpectedSize:(CGFloat)scrollLocation animated:(BOOL)animated
{
    CGSize expectedMinimumContentSize = self.tableView.contentSize;
    if (expectedMinimumContentSize.height < scrollLocation) {
        // Temporarily expand the content area to contain the scroll location.
        // The table will overwrite this during the update process.
        expectedMinimumContentSize.height = scrollLocation;
        self.tableView.contentSize = expectedMinimumContentSize;
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, scrollLocation-1, 1, 1) animated:animated];
}

@end
