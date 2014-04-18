//
//  TLTransitionLayout.h
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

/**
 A subclass of `UICollectionViewTransitionLayout` that interpolates linearly between
 layouts and optionally content offsets. The target offset can be specified directly
 by setting the `toContentOffset` property. The `UICollectionView+TLTransitioning` category
 provides API for calculating useful values for `toContentOffset`.
 
 When the transition is finalized, the collection view will set `contentOffset`
 back to it's original value. To negate this, one can set it back to the value
 of `toContentOffset` in the transition's completion block. This class conforms
 to the `TLTransitionAnimatorLayout` protocol, so when used with
 `[UICollectionView+TLTransitioning transitionToCollectionViewLayout:duration:completion:]`,
 this negation happens automatically.
 */

#import <UIKit/UIKit.h>
#import "UICollectionView+TLTransitioning.h"

@interface TLTransitionLayout : UICollectionViewTransitionLayout <TLTransitionAnimatorLayout>

/**
 Initializer with additional `supplementaryKinds` argument used to inform the layout
 what supplementary view kinds are registered with the collection view. This parameter
 must be supplied in order to support supplementary views.
 */
- (id)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout supplementaryKinds:(NSArray *)supplementaryKinds;

/**
 When specified, the content offset will be transitioned from the current value
 to this value.
 */
 @property (nonatomic) CGPoint toContentOffset;

/**
 The initial content offset.
 */
@property (readonly, nonatomic) CGPoint fromContentOffset;

/**
 The current relative time in terms of the transition progress. The value varies
 from 0 to 1 over the course of the transition. The value is equal to `transitionProgress`
 unless progress is being updated through calls to `setTransitionProgress:time:`.
 If `setTransitionProgress:time:` is being used, `transitionTime` progresses linearly,
 regardless of the easing curve being used. This can be useful when some elements
 of the transition need to progress along another easing curve, which can be accomplished
 by passing `transitionTimee` to another easing function.
 */
@property (readonly, nonatomic) CGFloat transitionTime;

/**
 */
- (void)cancelInPlace;

@property (readonly, nonatomic) BOOL cancelledInPlace;

/**
 Optional callback to modify the interpolated layout attributes. Can be used to
 customize the animation. Return a non-nil value to replace the given `layoutAttributes` 
 with the returned instance.
 */
@property (strong, nonatomic) UICollectionViewLayoutAttributes *(^updateLayoutAttributes)(UICollectionViewLayoutAttributes *layoutAttributes, UICollectionViewLayoutAttributes *fromAttributes, UICollectionViewLayoutAttributes *toAttributes, CGFloat progress);

/**
 Set the transition progress and time. This method can optionally be called instead
 of `setTransitionProgress` when the transition is following a non-linear easing
 curve and there is a need to know the linear time. This can be useful when some
 elements of the transition need to progress along another easing curve, which can
 be accomplished by passing the value of `transitionTimee` to another easing function.
 The `transitionToCollectionViewLayout:duration:easing:completion transition in
 `UICollectionView+Transitioning` utilizes this feature.
 */
- (void)setTransitionProgress:(CGFloat)transitionProgress time:(CGFloat)time;

/**
 Optional callback when progress changes. Can be used to modify things outside of the
 scope of the layout.
 */
@property (strong, nonatomic) void(^progressChanged)(CGFloat progress);

@end
