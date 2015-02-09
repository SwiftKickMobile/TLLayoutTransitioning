//
//  TLTreeTableViewController.h
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

#import "TLTableViewController.h"
#import "TLTreeDataModel.h"
#import "TLIndexPathTreeItem.h"

/**
 Basic view controller implementation for `TLTreeDataModel` with support for expanding
 and collapsing rows. Also supports lazy loading child items. The controller treats
 a `TLIndexPathTreeItem` with `childItems == nil` as a leaf node and will not attempt
 to expand or collapse the item. So for items that will have lazy loaded children,
 the child items should be set to an empty array.
 */

@class TLTreeTableViewController;

@protocol TLTreeTableViewControllerDelegate <NSObject>
@optional

/**
 Gives the delegate an opportunity to decide if a node should be expanded or collapsed when selected.
 */
- (BOOL)controller:(TLTreeTableViewController *)controller shouldChangeNode:(TLIndexPathTreeItem *)treeItem collapsed:(BOOL)collapsed;

/**
 Gives the delegate an opportunity to make changes before the node is expanded.
 This can be used to lazy load child items on expand or prune child items on collapse
 with a call to `setNewVersionOfItem:collapsedChildNodeIdentifiers`.

 If the app needs to load child nodes asynchronously, this method should be used to initiate
 the fetch and then call `setNewVersionOfItem:collapsedChildNodeIdentifiers` in the
 completion handler of the fetch.
 */
- (void)controller:(TLTreeTableViewController *)controller willChangeNode:(TLIndexPathTreeItem *)treeItem collapsed:(BOOL)collapsed;

/**
 Called after a node is expanded or collapsed so the delegate can make any needed updates,
 such as toggling an expand/collapse icon.
 */
- (void)controller:(TLTreeTableViewController *)controller didChangeNode:(TLIndexPathTreeItem *)treeItem collapsed:(BOOL)collapsed;

@end

@interface TLTreeTableViewController : TLTableViewController

@property (weak, nonatomic) id<TLTreeTableViewControllerDelegate>delegate;

/**
 Replaces an existing item with a new version. If there is no item in the existing
 tree with a matching identifier, no change is made. Use this method to lazy load child
 nodes asynchrnously when a node is expanded.
 */
- (void)setNewVersionOfItem:(TLIndexPathTreeItem *)item collapsedChildNodeIdentifiers:(NSArray *)collapsedChildNodeIdentifiers optimizeScroll:(BOOL)optimizeScroll;
- (void)setNewVersionOfItem:(TLIndexPathTreeItem *)item collapsedChildNodeIdentifiers:(NSArray *)collapsedChildNodeIdentifiers DEPRECATED_ATTRIBUTE;

/**
 A type-safe shortcut for getting and setting the tree data model on the
 underlying index path controller.
 */
@property (strong, nonatomic) TLTreeDataModel *dataModel;

@end
