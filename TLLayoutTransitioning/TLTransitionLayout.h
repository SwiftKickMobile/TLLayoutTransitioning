//
//  TLTransitionLayout.h
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionView+TLTransitionAnimator.h"

typedef NS_ENUM(NSInteger, TLTransitionLayoutKeyIndexPathPlacement) {
    /**
     Moves the key item's center point the minimal amount to be displayed
     fully on screen.
     */
    TLTransitionLayoutKeyIndexPathPlacementNone,

    /**
     Moves the key item's center point to the center of the collection view's bounds
     */
    TLTransitionLayoutKeyIndexPathPlacementCenter,
};

@interface TLTransitionLayout : UICollectionViewTransitionLayout <TLTransitionAnimatorLayout>

@property (strong, nonatomic) NSIndexPath *keyIndexPath;

@property (nonatomic) TLTransitionLayoutKeyIndexPathPlacement keyIndexPathPlacement;

@property (nonatomic) CGPoint toContentOffset;

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
