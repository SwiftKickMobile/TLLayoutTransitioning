//
//  TLCollectionViewController.m
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

#import "TLCollectionViewController.h"
#import "TLIndexPathItem.h"

@interface TLCollectionViewController ()
@property (strong, nonatomic) NSMutableDictionary *viewControllerByCellInstanceId;
@end

@implementation TLCollectionViewController

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

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _indexPathController = [[TLIndexPathController alloc] init];
    _indexPathController.delegate = self;
}

#pragma mark - Index path controller

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    if (_indexPathController != indexPathController) {
        _indexPathController = indexPathController;
        _indexPathController.delegate = self;
        [self.collectionView reloadData];
    }
}

#pragma mark - Configuration

- (void)collectionView:(UICollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)reconfigureVisibleCells
{
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self collectionView:self.collectionView configureCell:cell atIndexPath:indexPath];
    }
}

- (NSString *)collectionView:(UICollectionView *)collectionView cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
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

- (UIViewController *)collectionView:(UICollectionView *)collectionView viewControllerForCell:(UICollectionViewCell *)cell
{
    NSString *key = [self instanceId:cell];
    UIViewController *controller = [self.viewControllerByCellInstanceId objectForKey:key];
    
    // There is a bug (or behavior) in iOS7.4 where cells are not reused. See
    // http://stackoverflow.com/questions/19276509/uicollectionview-do-not-reuse-cells/20147799#20147799
    // This causes a problem with our implementation because we're using the cell's
    // memory address as a lookup key for the cell's backing view controller. When
    // cells aren't re-used, they get deallocated and their memory address might get
    // reused. When this happens, the new cell gets associated with the backing
    // congroller of of the deallocated cell. And this new cell doesn't actually
    // have the view controller's view installed in its view heirarchy. This workaround
    // simply check if the view controller's view doesn't have a superview. If it
    // does not, it is assumed that we've got the wrong view controller and it
    // should be discarded.
    if (controller && [controller.view superview] == nil) {
        controller = nil;
        [self.viewControllerByCellInstanceId removeObjectForKey:key];
    }
    
    if (!controller) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        controller = [self collectionView:collectionView instantiateViewControllerForCell:cell atIndexPath:indexPath];
        if (controller) {
            [self setViewController:controller forKey:key];
        }
    }

    return controller;
}

- (UIViewController *)collectionView:(UICollectionView *)collectionView instantiateViewControllerForCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)instanceId:(id)object
{
    return [NSString stringWithFormat:@"%p", object];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self collectionView:collectionView cellIdentifierAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    UIViewController *controller = [self collectionView:collectionView viewControllerForCell:cell];
    if (controller && self.establishContainmentRelationshipWithViewControllerForCell) {
        [self addChildViewController:controller];
    }
    [self collectionView:collectionView configureCell:cell atIndexPath:indexPath];
    return cell;
}

/**
 The default implementation supports single header and footer views for flow layouts.
 Override this as needed.
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    //TODO Support multiple possible header and footer views
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        identifier = @"Header";
    } else if ([UICollectionElementKindSectionFooter isEqualToString:kind]) {
        identifier = @"Footer";
    }
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = [self collectionView:collectionView viewControllerForCell:cell];
    [controller removeFromParentViewController];
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    //only perform batch udpates if view is visible
    if (self.isViewLoaded && self.view.window) {
        [updates performBatchUpdatesOnCollectionView:self.collectionView];
    } else {
        [self.collectionView reloadData];
    }
}

@end
