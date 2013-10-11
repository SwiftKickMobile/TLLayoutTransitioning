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

/**
 A protocol that can be implemented by `UICollectionViewTransitionLayout` subclasses
 to recieve a message when transition completion handler is called (`TLTransitionAnimator`
 holds onto the layout long enough to send this message). This can be used to perform
 any cleanup. Particularly, there may be properties that get reset to their original
 values after the transition, such as `contentOffset`, that the layout wants to set
 back to the target values. See usage in `TLTransitionLayout`.
 */

@protocol TLTransitionAnimatorLayout <NSObject>
- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView completed:(BOOL)completed finish:(BOOL)finish;
@end

/**
 A category on `UICollectionView` that for non-interactive, animated transitioning between layouts using
 `UICollectionViewTransitionLayout` with the ability to specify a transition duration.
 This can be used, for example, to gain finer control than what is possible with
 `setCollectionViewLayout:animated:completion:`. Can be used with `TLTransitionLayout`
 to mimick the behavior of `setCollectionViewLayout:animated:completion:`, but with
 improved behavior (see the Resize sample project).
 */

@interface UICollectionView (TLTransitionAnimator)

/**
 Transitions to the new layout like `startInteractiveTransitionToCollectionViewLayout`
 except that the process is not interactive and one can specify a duration.
 */
- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration completion:(UICollectionViewLayoutInteractiveTransitionCompletion) completion;

@end
