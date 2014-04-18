//
//  TLTableViewController.m
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
#import "TLIndexPathItem.h"
#import "TLDynamicSizeView.h"

@interface TLTableViewController ()
@property (strong, nonatomic) NSMutableDictionary *prototypeCells;
@property (strong, nonatomic) NSMutableDictionary *viewControllerByCellInstanceId;
@end

@implementation TLTableViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _indexPathController = [[TLIndexPathController alloc] init];
    _indexPathController.delegate = self;
    _rowAnimationStyle = UITableViewRowAnimationFade;
}

#pragma mark - Index path controller

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    if (_indexPathController != indexPathController) {
        _indexPathController = indexPathController;
        _indexPathController.delegate = self;
        [self.tableView reloadData];
    }
}

#pragma mark - Configuration

- (NSString *)tableView:(UITableView *)tableView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    NSString *cellId;
    if ([item isKindOfClass:[TLIndexPathItem class]]) {
        TLIndexPathItem *i = item;
        cellId = i.cellIdentifier;
    }
    if (cellId.length == 0) {
        cellId = @"Cell";
    }
    return cellId;

}

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)reconfigureVisibleCells
{
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self tableView:self.tableView configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - Prototype cells

- (UITableViewCell *)tableView:(UITableView *)tableView prototypeForCellIdentifier:(NSString *)cellIdentifier
{
    UITableViewCell *cell;
    if (cellIdentifier) {
        cell = [self.prototypeCells objectForKey:cellIdentifier];
        if (!cell) {
            if (!self.prototypeCells) {
                self.prototypeCells = [[NSMutableDictionary alloc] init];
            }
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            //this will cause a view controller to be configured for the prototype cell
            //if there's supposed to be one
            [self tableView:tableView viewControllerForCell:cell];
            //TODO this will fail if multiple tables are being used and they have
            //overlapping identifiers. The key needs to be unique to the table
            [self.prototypeCells setObject:cell forKey:cellIdentifier];
        }
    }
    return cell;

}

#pragma mark - Backing cells with view controllers

- (void)setViewController:(UIViewController *)controller forKey:(NSString *)key
{
    if (!self.viewControllerByCellInstanceId) {
        self.viewControllerByCellInstanceId = [NSMutableDictionary dictionary];
    }
    UIViewController *currentViewController = [self.viewControllerByCellInstanceId objectForKey:key];
    if (currentViewController) {
        [currentViewController.view removeFromSuperview];
        [currentViewController removeFromParentViewController];
    }
    [self.viewControllerByCellInstanceId setObject:controller forKey:key];
}

- (UIViewController *)tableView:(UITableView *)tableView viewControllerForCell:(UITableViewCell *)cell
{
    NSString *key = [self instanceId:cell];
    UIViewController *controller = [self.viewControllerByCellInstanceId objectForKey:key];
    
    // This bit of code solves an issue in `TLCollectionViewController` (see the comments
    // there) and is included here for good measure.
    if (controller && [controller.view superview] == nil) {
        controller = nil;
        [self.viewControllerByCellInstanceId removeObjectForKey:key];
    }
    
    if (!controller) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        controller = [self tableView:tableView instantiateViewControllerForCell:cell atIndexPath:indexPath];
        if (controller) {
            [self setViewController:controller forKey:key];
        }
    }
    return controller;
}

- (UIViewController *)tableView:(UITableView *)tableView instantiateViewControllerForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)instanceId:(id)object
{
    return [NSString stringWithFormat:@"%p", object];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [self tableView:tableView cellIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    UIViewController *controller = [self tableView:tableView viewControllerForCell:cell];
    if (controller) {
        [self addChildViewController:controller];
    }
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel sectionTitleForSection:section];
}

/**
 Automatically calculate cell height by retrieving a prototype and either a)
 returning the existing height or b) if the cell implements the `TLDynamicHeightView`
 protocol, returning the value of sizeWithData:. For (b), the data passed to the
 cell will be the item returned by the data model or, if the item is an instance
 of `TLIndexPathItem`, the value of the item's `data` property.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    NSString *cellId = [self tableView:tableView cellIdentifierAtIndexPath:indexPath];
    if (cellId) {
        UITableViewCell *cell = [self tableView:tableView prototypeForCellIdentifier:cellId];
        if ([cell conformsToProtocol:@protocol(TLDynamicSizeView)]) {
            id<TLDynamicSizeView> v = (id<TLDynamicSizeView>)cell;
            id data;
            if ([item isKindOfClass:[TLIndexPathItem class]]) {
                TLIndexPathItem *i = (TLIndexPathItem *)item;
                data = i.data;
            } else {
                data = item;
            }
            CGSize computedSize = [v sizeWithData:data];
            return computedSize.height;
        } else {
            return cell.bounds.size.height;
        }
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = [self tableView:tableView viewControllerForCell:cell];
    [controller removeFromParentViewController];
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    //only perform batch udpates if view is visible
    if (self.isViewLoaded && self.view.window) {
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:self.rowAnimationStyle];
    } else {
        [self.tableView reloadData];
    }
}

@end
