//
//  UICollectionView+TransitionLayoutAnimator.h
//  HomeStory
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */

@protocol TLTransitionAnimatorLayout <NSObject>
- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView completed:(BOOL)completed finish:(BOOL)finish;
@end

/**
 A simple category animated transitioning between layouts using `UICollectionViewTransitionLayout`
 with the ability to specify a transition duration.
 */

@interface UICollectionView (TLTransitionAnimator)

/**
 
 */
- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion;

@end
