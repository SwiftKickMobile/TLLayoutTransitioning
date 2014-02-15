//
//  UICollectionView+TransitionLayoutAnimator.h
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
#import "easing.h"

typedef NS_ENUM(NSInteger, TLTransitionLayoutIndexPathPlacement) {

    /**
     Sets the content offset such that the center point of the specified cell
     or cells moves as little as possible. For example, use this option to miminimze
     motion of a tapped cell.
     */
    TLTransitionLayoutIndexPathPlacementMinimal,

//TODO
//    /**
//     Sets the content offset such that the center point of the specified cell
//     or cells moves as little as possible while being as visible as possible.
//     For example, use this option to minimize motion of a specific cell that
//     might not be currently visible but should become visible.
//     */
//    TLTransitionLayoutIndexPathPlacementVisible,

    /**
     Sets the content offset such that the center point of the specified cell
     or cells is as close to the center of the collection view's frame as possible.
     For example, Use this option to center a tapped cell.
     */
    TLTransitionLayoutIndexPathPlacementCenter,

    /**
     Sets the content offset such that the top center point of the specified cell
     or cells is as close to the top center of the collection view's frame as
     possible. For example, use this option to place a tapped cell at the top.
     */
    TLTransitionLayoutIndexPathPlacementTop,

    /**
     Sets the content offset such that the left center point of the specified cell
     or cells is as close to the left center of the collection view's frame as
     possible. For example, use this option to place a tapped cell on the left.
     */
    TLTransitionLayoutIndexPathPlacementLeft,

    /**
     Sets the content offset such that the bottom center point of the specified cell
     or cells is as close to the bottom center of the collection view's frame as
     possible. For example, use this option to place a tapped cell at the bottom.
     */
    TLTransitionLayoutIndexPathPlacementBottom,

    /**
     Sets the content offset such that the right center point of the specified cell
     or cells is as close to the right center of the collection view's frame as
     possible. For example, use this option to place a tapped cell on the right.
     */
    TLTransitionLayoutIndexPathPlacementRight,
};

/**
 A protocol that can be implemented by `UICollectionViewTransitionLayout` subclasses
 to recieve a message when transition completion handler is called (`TLTransitioning`
 holds onto the layout long enough to send this message). This can be used to perform
 any cleanup. Particularly, there may be properties that get reset to their original
 values after the transition, such as `contentOffset`, that the layout wants to set
 back to the target values. See usage in `TLTransitionLayout`.
 */

@protocol TLTransitionAnimatorLayout <NSObject>
- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView completed:(BOOL)completed finish:(BOOL)finish;
@end

/**
 A category on `UICollectionView` that provides a variety of utility methods and calculations
 for interactive transitioning.
 */

@interface UICollectionView (TLTransitioning)

#pragma mark - Performing transitions

/**
 Transitions to the new layout like `startInteractiveTransitionToCollectionViewLayout`
 except that the process is not interactive and one can specify a duration. This can be used,
 for example, to gain finer control than what is possible with
 `setCollectionViewLayout:animated:completion:`. Can be used with `TLTransitionLayout`
 to mimick the behavior of `setCollectionViewLayout:animated:completion:`, but with
 improved behavior (see the Resize sample project).
 */
- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration easing:(AHEasingFunction)easingFunction completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion;

- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion __deprecated;

#pragma mark - Calculating transition values

/**
 Calculate the transition progress, given initial, current, and final values
 and an easing function. Easing functions courtesy of Warren Moore's AHEasing library
 https://github.com/warrenm/AHEasing
 */
CGFloat transitionProgress(CGFloat initialValue, CGFloat currentValue, CGFloat finalValue, AHEasingFunction easingFunction);

/**
 Calculate the final content offset for the given transition layout that place the
 specified index paths at a particular location. Specify a single index path for pinching
 or tapping a cell. Specify multiple index paths for pinching a group of cells,
 for example, like a stack of photos.
 */
- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout indexPaths:(NSArray *)indexPaths placement:(TLTransitionLayoutIndexPathPlacement)placement;

@end
