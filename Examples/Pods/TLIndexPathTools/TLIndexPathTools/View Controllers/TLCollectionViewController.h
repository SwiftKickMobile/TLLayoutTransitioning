//
//  TLCollectionViewController.h
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

/**
 A subclass of `UICollectionViewController` that works with `TLIndexPathController`
 and provide default impelementations of the essential data source and delegate
 methods to get your collection views up-and-running as quickly as possible.
 
 This class also supports view controller-backed cells.
 */

#import "TLIndexPathController.h"

@interface TLCollectionViewController : UICollectionViewController <TLIndexPathControllerDelegate>

/**
 The collection view's index path controller. A default controller is
 created automatically with `nil` for `identifierKeyPath`, `sectionNameKeyPath`.
 It is not uncommon to replace this default instance with a custom 
 controller. For example, if Core Data is being used, one would
 typically provide a controller created with the
 `initWithFetchRequest:managedObjectContext:sectionNameKeyPath:identifierKeyPath:cacheName:`
 initializer.
 */
@property (strong, nonatomic) TLIndexPathController *indexPathController;

/**
 The implementation of `collectionView:cellForItemAtIndexPath:` calls this method
 to ask for the cell's identifier before attempting to dequeue a cell. The default
 implementation of this method first asks the data model for an identifier and,
 if none is provided, returns the "Cell". Data models that don't use
 `TLIndexPathItem` as their item type typically return `nil` and so it is not
 uncommon to override this method with custom logic.
 */
- (NSString *)collectionView:(UICollectionView *)collectionView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;

/*
 This method is intended to be overridden with the cell's configuration logic.
 It is called by by this classes implementation of `collectionView:cellForItemAtIndexPath:`
 after the cell has been created/dequeued. The default implementation does nothing.
 
 Alternatively, one can override `collectionView:cellForItemAtIndexPath:` and either
 call the super implementation to get the unconfigured cell or or create/dequeue
 the cell directly.
 */
- (void)collectionView:(UICollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)reconfigureVisibleCells;

#pragma mark - Backing cells with view controllers

/**
 This method should be overridden to enable view controller-backed cells. The default
 implementation returns `nil`. If this method returns a view controller for the given
 cell and index path, the table view controller will automatically install the backing
 controller as a child view controller in `cellForItemAtIndexPath` and uninstall it
 in `collectionView:didEndDisplayingCell:forItemAtIndexPath:`. This method is responsible
 for installing the view controller's view into the cell's view heirarchy.
 */
- (UIViewController *)collectionView:(UICollectionView *)collectionView instantiateViewControllerForCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the backing view controller for the given cell, if any. This method is used
 internally and can also be called in custom code, for example when configuring the
 cell in `cellForItemAtIndexPath`. To enable view controller-backed cells, override
 the companion method `collectionView:instantiateViewControllerForCell:atIndexPath:`.
 */
- (UIViewController *)collectionView:(UICollectionView *)collectionView viewControllerForCell:(UICollectionViewCell *)cell;

/**
 If set to NO, the view controller will not establish a containment relationship
 with view controllers instantiated for cells. This option exists because cases have
 been observed where the collection view can get in a bad state where cells fail
 to be removed from view as they move offscreen during an interactive transition.
 This seems to be a collection view bug and no workaround has been found. If you're
 not experiencing this issue, stick with the default value of YES to retain all of
 the normal view controller view containment behavior (view appearance calls,
 screen rotation calls, etc.).
 */
@property (nonatomic) BOOL establishContainmentRelationshipWithViewControllerForCell;

@end
