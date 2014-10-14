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
     */
    TLTransitionLayoutIndexPathPlacementNone,

    /**
     Sets the content offset such that the center point of the specified cell
     or cells moves as little as possible. For example, use this option to miminimze
     motion of a tapped cell.
     */
    TLTransitionLayoutIndexPathPlacementMinimal,

    /**
     Sets the content offset such that the specified cell or or cells end up
     as visible as possible with a secondary goal of moving as little as possible.
     For example, use this option to minimize motion of a specific cell that
     might not be currently visible or be partially obscured,, but should become
     fully visible.
     */
    TLTransitionLayoutIndexPathPlacementVisible,

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
 A constant representing the default placement anchor point
 */
extern CGPoint kTLPlacementAnchorDefault;

/**
 A protocol that can be implemented by `UICollectionViewTransitionLayout` subclasses
 to recieve a message when transition completion handler is called (`TLTransitioning`
 holds onto the layout long enough to send this message). This can be used to perform
 any cleanup. Particularly, there may be properties that get reset to their original
 values after the transition, such as `contentOffset`, that the layout wants to set
 back to the target values. See usage in `TLTransitionLayout`.
 */

@protocol TLTransitionAnimatorLayout <NSObject>
- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView
                                     completed:(BOOL)completed finish:(BOOL)finish;
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
- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout
                                                              duration:(NSTimeInterval)duration
                                                                easing:(AHEasingFunction)easingFunction
                                                            completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion;

- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout
                                                              duration:(NSTimeInterval)duration
                                                            completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion __deprecated;

/**
 Returns `YES` if an interactive transition started by a call to
 `transitionToCollectionViewLayout` is currently in progress.
 */
- (BOOL)isInteractiveTransitionInProgress;

/**
 Cancels an in-flight transition started by a call to `transitionToCollectionViewLayout`.
 Can be used to start a new transition before the current transition completes, for example,
 if the screen rotates while a transition is in progress. NOTE that this method does not
 currently work with layouts that have supplementary or decorative views.
 */
- (void)cancelInteractiveTransitionInPlaceWithCompletion:(void(^)())completion;

#pragma mark - Calculating transition values

/**
 Calculate the transition progress, given initial, current, and final values
 and an easing function. Easing functions courtesy of Warren Moore's AHEasing library
 https://github.com/warrenm/AHEasing
 */
CGFloat transitionProgress(CGFloat initialValue, CGFloat currentValue, CGFloat finalValue, AHEasingFunction easingFunction);

/**
 Same as `toContentOffsetForLayout:indexPaths:placement:placementAnchor:placementInset:toSize:toContentInset`
 with fewer options.
 */
- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement;
/**
 Calculate the final content offset for the given transition layout that place the
 specified index paths at a particular location. Specify a single index path for pinching
 or tapping a cell. Specify multiple index paths for pinching a group of cells,
 for example, like a stack of photos. Numerous options are provided to fine-tune
 the placement.
 
 @param layout  the transition layout instance
 @param indexPaths  the collection of index paths to consider for placement
 @param placement  the type of placement, e.g. Center
 @param placementAnchor  the relative placement anchor point. Specify kTLPlacementAnchorDefault
                         for the default anchor, which varies by placement type.
 @param placementInset  the inset on the collection view's frame for placement.
                        Specify UIEdgeInsetsZero for no inset.
 @param toSize  The expected "to" size of the collection view's frame. Use this
                option when resizing the collection view during the transition.
                Specify `collectionView.bounds.size` when not resizing.
 @param toContentInset  The expected "to" content inset. Use this option when
                        modifying the content inset during the transition. Specify
                        `collectionView.contentInset` when not changing the inset.

 The `placement` argument determines how the content offset is calculated. Regardess
 of the placement type, the caculations are based on the union of all frames in the
 given collection of `indexPaths`, i.e. the placement frame. The `placementAnchor`
 and `placementInset` arguments can be used to further control the placement behavior.
 
 The `placementAnchor` argument specifies the relative point in the placement frame
 for which the offset is calculated. For example, the Minimal placement type has a 
 default placement anchor of {0.5, 0.5}, which means the movement of the center of
 the placement frame is minimized. However, a placement anchor of {0.5, 0} will
 minimize the movement of the top-center point.
 
 The `placementInset` argument insets the placement frame. For example, the Visible
 placement type will position a hidden cell along the edge of the collection view.
 To provide a margin between the cell and the edge of the collection view, specify
 a positive inset, such as {20, 20, 20, 20}.
 */
- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
                    placementAnchor:(CGPoint)placementAnchor
                     placementInset:(UIEdgeInsets)placementInset
                             toSize:(CGSize)toSize
                     toContentInset:(UIEdgeInsets)toContentInset
                                ;

- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
                             toSize:(CGSize)toSize
                     toContentInset:(UIEdgeInsets)toContentInset __deprecated;

/**
 Interpolate between initial and final frames given the transition progress
 */
extern CGRect TLTransitionFrame(CGRect fromFrame, CGRect toFrame, CGFloat progress);

/**
 Interpolate between initial and final points given the transition progress
 */
extern CGPoint TLTransitionPoint(CGPoint fromPoint, CGPoint toPoint, CGFloat progress);

/**
 Interpolate between initial and final sizes given the transition progress
 */
extern CGSize TLTransitionSize(CGSize fromSize, CGSize toSize, CGFloat progress);

/**
 Interpolate between initial and final float values given the transition progress
 */
extern CGFloat TLTransitionFloat(CGFloat fromFloat, CGFloat toFloat, CGFloat progress);

/**
 Interpolate between initial and final edge insets given the transition progress
 */
extern UIEdgeInsets TLTransitionInset(UIEdgeInsets fromInset, UIEdgeInsets toInset, CGFloat progress);

/**
 Converts the current time into a subordinate timespace, usefull for for simulating
 things like delay and duration within the overall transition timespace. This converted
 time can be supplied to easing functions for custom animation behavior of elements
 within the overall duration. For example, to simulate a relative duration of 0.5
 and delay of 0.5, the following calls to `TLConvertTime` would look like:
 
     0.00 => 0.0 : TLConvertTime(0.00, 0.25, 0.75)
     0.25 => 0.0 : TLConvertTime(0.25, 0.25, 0.75) // converted start
     0.50 => 0.5 : TLConvertTime(0.50, 0.25, 0.75)
     0.75 => 1.0 : TLConvertTime(0.75, 0.25, 0.75) // converted end
     1.00 => 1.0 : TLConvertTime(1.00, 0.25, 0.75)
 
 The converted time varies from 0 to 1 during the time that the overall time varies
 from 0.25 to 0.75.
 */
extern CGFloat TLConvertTimespace(CGFloat time, CGFloat startTime, CGFloat endTime);

/**
 Calculates the relative position of `point` in `rect`. For example, point {1, 2}
 in {{0, 0}, {2, 2}} would return {0.5, 1}. Useful for converting touches for
 the `placementAnchor` argument of `toContentOffsetForLayout`.
 */
extern CGPoint TLRelativePointInRect(CGPoint point, CGRect rect);

@end
