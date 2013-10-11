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
 A subclass of `UICollectionViewTransitionLayout` that supports `contentOffset` change.
 The target offset can be specified directly by setting the `toContentOffset` property
 or indirectly by setting the `keyIndexPath`. The later method is useful for controlling
 the final position of a specific item, typically a selected item (currently, the key 
 item is positioned as close to the center as possible).
 
 When the transition is finalized, the collection view will set `contentOffset`
 back to it's original value. To negate this, one can set it back to the value
 of `toContentOffset` in the transition's completion block. This class conforms
 to the `TLTransitionAnimatorLayout` protocol, so when used with `TLTransitionAnimator`
 category, this negation happens automatically.
 */

#import <UIKit/UIKit.h>
#import "UICollectionView+TLTransitionAnimator.h"

typedef NS_ENUM(NSInteger, TLTransitionLayoutKeyIndexPathPlacement) {
    /**
     Sets the content offset such that the key item's center point is as close to
     the center of the collection view's bounds as possible.
     */
    TLTransitionLayoutKeyIndexPathPlacementCenter,
//TODO
//
//    /**
//     Sets the content offset such that the the key item's center point
//     moves as little as possible to be fully visible.
//     */
//    TLTransitionLayoutKeyIndexPathPlacementVisible,
//
//    /**
//     Sets the content offset such that the the key item's center point
//     moves as little as possible.
//     */
//    TLTransitionLayoutKeyIndexPathPlacementNone,
};

@interface TLTransitionLayout : UICollectionViewTransitionLayout <TLTransitionAnimatorLayout>

/**
 When specified, the content offset will be transitioned from the current value
 to this value. Can be set explicitly or implicitly through `keyIndexPath`.
 */
 @property (nonatomic) CGPoint toContentOffset;
 

/**
 If set, the `toContentProperty` will be calculated such that the key item is
 positioned according to the value of `keyIndexPathPlacement`. Typically, the
 `keyIndexPath` would be set to a selected item.
 */
@property (strong, nonatomic) NSIndexPath *keyIndexPath;

/**
 Specifies the positioning mode when using `keyIndexPath` to calculate the
 `toContentOffset`. Defaults to `TLTransitionLayoutKeyIndexPathPlacementCenter`.
 */
@property (nonatomic) TLTransitionLayoutKeyIndexPathPlacement keyIndexPathPlacement;

/**
 Optional callback to modify the interpolated layout attributes. Can be used to customize the
 animation or to substitute a custom `UICollectionViewLayoutAttributes` subclass.
 */
@property (strong, nonatomic) UICollectionViewLayoutAttributes *(^updateLayoutAttributes)(UICollectionViewLayoutAttributes *layoutAttributes);

/**
 Optional callback when progress changes. Can be used to modify things outside of the
 scope of the layout
 */
@property (strong, nonatomic) void(^progressChanged)(CGFloat progress);

@end
