//
//  TLTableViewController.h
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

#import <UIKit/UIKit.h>

#import "TLIndexPathController.h"

/**
 A subclass of `UITableViewController` that works with `TLIndexPathController`
 and provide default impelementations of the essential data source and delegate
 methods to get your table views up-and-running as quickly as possible.
 
 This class also supports view controller-backed cells and automatically
 calculates static or dynamic cell heights using prototype cells. For dynamic
 height cells, the cell must implement the `DynamicSizeView` protocol.
 */

@interface TLTableViewController : UITableViewController <TLIndexPathControllerDelegate>

/**
 The table view's index path controller. A default controller is
 created automatically with `nil` for `identifierKeyPath`, `sectionNameKeyPath`
 and `cellIdentifierKeyPath`. It is not uncommon to replace this default instance
 with a custom controller. For example, if Core Data is being used, one would
 typically provide a controller created with the
 `initWithFetchRequest:managedObjectContext:sectionNameKeyPath:identifierKeyPath:cacheName:`
 initializer.
 */
@property (strong, nonatomic) TLIndexPathController *indexPathController;

/**
 Set this property to specify the row animation style.
 Defaults to UITableViewRowAnimationAutomatic.
 */
@property (nonatomic) UITableViewRowAnimation rowAnimationStyle;

/**
 The implementation of `tableView:cellForRowAtIndexPath:` calls this method
 to ask for the cell's identifier before attempting to dequeue a cell. The default
 implementation of this method first asks the data model for an identifier and,
 if none is provided, returns the "Cell". Data models that don't use 
 `TLIndexPathItem` as their item type typically return `nil` and so it is not
 uncommon to override this method with custom logic.
 */
- (NSString *)tableView:(UITableView *)tableView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;

/*
 This method is intended to be overridden with the cell's configuration logic.
 It is called by by this classes implementation of `tableView:cellForRowAtIndexPath:`
 after the cell has been created/dequeued. The default implementation does nothing.
 
 Alternatively, one can override `tableView:cellForRowAtIndexPath:` and either
 call the super implementation to get the unconfigured cell or or create/dequeue
 the cell directly.
 */
- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)reconfigureVisibleCells;

#pragma mark - Prototype cells

/**
 Returns a prototype instance of the specified cell. This can be useful for getting
 basic information about the table view's cells outside of the scope of any specific
 cell. For example, this method is used internally to automatically calculate
 the cell's height in `tableView:heightForRowAtIndexPath:`.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView prototypeForCellIdentifier:(NSString *)cellIdentifier;

#pragma mark - Backing cells with view controllers

/**
 This method should be overridden to enable view controller-backed cells. The default
 implementation returns `nil`. If this method returns a view controller for the given
 cell and index path, the table view controller will automatically install the backing
 controller as a child view controller in `cellForRowAtIndexPath` and uninstall it
 in `tableView:didEndDisplayingCell:forRowAtIndexPath:`. This method is responsible
 for installing the view controller's view into the cell's view heirarchy.
 */
- (UIViewController *)tableView:(UITableView *)tableView instantiateViewControllerForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the backing view controller for the given cell, if any. This method is used
 internally and can also be called in custom code, for example when configuring the
 cell in `cellForRowAtIndexPath`. To enable view controller-backed cells, override
 the companion method `tableView:instantiateViewControllerForCell:atIndexPath:`.
 */
- (UIViewController *)tableView:(UITableView *)tableView viewControllerForCell:(UITableViewCell *)cell;


@end
