//
//  TLTreeTableViewController.m
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

#import "TLTreeTableViewController.h"
#import "UITableViewController+ScrollOptimizer.h"
#import "TLIndexPathSectionInfo.h"
#import "UITableView+ScrollOptimizer.h"

@interface TLTreeTableViewController ()
@property (nonatomic) BOOL changingNode;
@end

@implementation TLTreeTableViewController

- (TLTreeDataModel *)dataModel {
    return (TLTreeDataModel *)self.indexPathController.dataModel;
}

- (void)setDataModel:(TLTreeDataModel *)dataModel
{
    self.indexPathController.dataModel = dataModel;
}

#pragma mark - Manipulating the tree

- (void)setNewVersionOfItem:(TLIndexPathTreeItem *)item collapsedChildNodeIdentifiers:(NSArray *)collapsedChildNodeIdentifiers
{
    [self setNewVersionOfItem:item collapsedChildNodeIdentifiers:collapsedChildNodeIdentifiers optimizeScroll:NO];
}

- (void)setNewVersionOfItem:(TLIndexPathTreeItem *)item collapsedChildNodeIdentifiers:(NSArray *)collapsedChildNodeIdentifiers optimizeScroll:(BOOL)optimizeScroll
{
    NSIndexPath *indexPath = [self.dataModel indexPathForIdentifier:item.identifier];
    if (indexPath) {
        
        NSArray *treeItemSections = self.dataModel.treeItemSections;
        NSMutableArray *newTreeItemSections = [NSMutableArray arrayWithCapacity:[treeItemSections count]];
        for (int section = 0; section < [treeItemSections count]; section++) {
            id<NSFetchedResultsSectionInfo> treeItemSection = treeItemSections[section];
            if (indexPath.section == section) {
                NSArray *newTreeItems = [self rebuildTreeItems:[treeItemSection objects] withNewVersionOfItem:item];
                TLIndexPathSectionInfo *newTreeItemSection = [[TLIndexPathSectionInfo alloc] initWithItems:newTreeItems
                                                                                                      name:treeItemSection.name
                                                                                                indexTitle:treeItemSection.indexTitle];
                [newTreeItemSections addObject:newTreeItemSection];
            } else {
                [newTreeItemSections addObject:treeItemSection];
            }
        }
        
        BOOL currentignoreDataModelChanges = self.indexPathController.ignoreDataModelChanges;
        if (self.changingNode) {
            self.indexPathController.ignoreDataModelChanges = YES;
        }
        //TODO to make this more robust, we should remove any existing children from the
        //current set of collapsed items. But what we've done here should work for
        //the simple case of lazy loading children.
        NSMutableArray *mergedCollapsed = [[NSMutableArray alloc] initWithArray:self.dataModel.collapsedNodeIdentifiers];
        [mergedCollapsed addObjectsFromArray:collapsedChildNodeIdentifiers];
        self.dataModel = [[TLTreeDataModel alloc] initWithTreeItemSections:newTreeItemSections collapsedNodeIdentifiers:mergedCollapsed];
        self.indexPathController.ignoreDataModelChanges = currentignoreDataModelChanges;
        if (optimizeScroll) {
            [self optimizeScrollForNodeAtIndexPath:indexPath];
        }
    }
}

- (NSArray *)rebuildTreeItems:(NSArray *)treeItems withNewVersionOfItem:(TLIndexPathTreeItem *)newVersionOfItem
{
    if (!treeItems) {
        return nil;
    }
    NSMutableArray *newTreeItems = [[NSMutableArray alloc] initWithCapacity:treeItems.count];
    for (TLIndexPathTreeItem *item in treeItems) {
        if ([newVersionOfItem.identifier isEqual:item.identifier]) {
            [newTreeItems addObject:newVersionOfItem];
        } else {
            NSArray *newChildItems = [self rebuildTreeItems:item.childItems withNewVersionOfItem:newVersionOfItem];
            TLIndexPathTreeItem *newItem = [item copyWithChildren:newChildItems];
            [newTreeItems addObject:newItem];
        }
    }
    return newTreeItems;
}

- (void)optimizeScrollForNodeAtIndexPath:(NSIndexPath *)indexPath
{
    id identifier = [self.dataModel identifierAtIndexPath:indexPath];
    if ([self.dataModel.collapsedNodeIdentifiers containsObject:identifier]) {
        return;
    }
    TLIndexPathTreeItem *item = (TLIndexPathTreeItem *)[self.dataModel itemAtIndexPath:indexPath];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    for (TLIndexPathTreeItem *childItem in item.childItems) {
        NSIndexPath *childIndexPath = [self.dataModel indexPathForItem:childItem];
        [indexPaths addObject:childIndexPath];
    }
    if ([indexPaths count] > 1) {
        [self.tableView optimizeScrollPositionForIndexPaths:indexPaths options:0 topInset:0 animated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathTreeItem *item = [self.dataModel itemAtIndexPath:indexPath];

    //use the convention that `childItems==nil` indicates a leaf node and only
    //perform the expand/collapse logic on non-leaf nodes
    if (item.childItems) {
        
        NSMutableArray *collapsedNodeIdentifiers = [NSMutableArray arrayWithArray:self.dataModel.collapsedNodeIdentifiers];
        //`collapsed` represents the __new__ state
        BOOL collapsed = ![collapsedNodeIdentifiers containsObject:item.identifier];

        if ([self.delegate respondsToSelector:@selector(controller:shouldChangeNode:collapsed:)]) {
            if (![self.delegate controller:self shouldChangeNode:item collapsed:collapsed]) {
                return;
            }
        }

        self.changingNode = YES;

        if ([self.delegate respondsToSelector:@selector(controller:willChangeNode:collapsed:)]) {
            [self.delegate controller:self willChangeNode:item collapsed:collapsed];
        }
        
        //reassign variables in case changes were made by the delegate
        item = [self.dataModel itemAtIndexPath:indexPath];
        collapsedNodeIdentifiers = [NSMutableArray arrayWithArray:self.dataModel.collapsedNodeIdentifiers];
        collapsed = ![collapsedNodeIdentifiers containsObject:item.identifier];
        
        if (collapsed == NO) {
            [collapsedNodeIdentifiers removeObject:item.identifier];
            for (TLIndexPathTreeItem *child in item.childItems) {
                if (child.childItems) {
                    [collapsedNodeIdentifiers addObject:child.identifier];
                }
            }
        } else {
            for (TLIndexPathTreeItem *child in item.childItems) {
                [collapsedNodeIdentifiers removeObject:child.identifier];
            }
            [collapsedNodeIdentifiers addObject:item.identifier];
        }
        
        NSArray *treeItemSections = self.dataModel.treeItemSections;
        self.dataModel = [[TLTreeDataModel alloc] initWithTreeItemSections:treeItemSections
                                                  collapsedNodeIdentifiers:collapsedNodeIdentifiers];
        
        if ([self.delegate respondsToSelector:@selector(controller:didChangeNode:collapsed:)]) {
            [self.delegate controller:self didChangeNode:item collapsed:collapsed];
        }
        
        if (!collapsed) {
            [self optimizeScrollForNodeAtIndexPath:indexPath];
        }
        
        self.changingNode = NO;
    }
}

@end
