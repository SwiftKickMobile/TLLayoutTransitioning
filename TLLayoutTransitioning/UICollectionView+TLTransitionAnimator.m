//
//  UICollectionView+TransitionLayoutAnimator.m
//  HomeStory
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 tractablelabs.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "UICollectionView+TLTransitionAnimator.h"
#import "TLTransitionLayout.h"

@implementation UICollectionView (TLTransitionAnimator)

#pragma mark - Simulated properties

static char kTLAnimationDurationKey;
static char kTLTransitionLayoutKey;

- (NSNumber *)tl_animationDuration
{
    return (NSNumber *)objc_getAssociatedObject(self, &kTLAnimationDurationKey);
}

- (void)tl_setAnimationDuration:(NSNumber *)duration
{
    objc_setAssociatedObject(self, &kTLAnimationDurationKey, duration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionViewTransitionLayout *)tl_transitionLayout
{
    return (UICollectionViewTransitionLayout *)objc_getAssociatedObject(self, &kTLTransitionLayoutKey);
}

- (void)tl_setTransitionLayout:(UICollectionViewTransitionLayout *)layout
{
    objc_setAssociatedObject(self, &kTLTransitionLayoutKey, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Transition logic

- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration completion:(UICollectionViewLayoutInteractiveTransitionCompletion)completion
{
    if (duration <= 0) {
        [NSException raise:@"" format:@""];//TODO
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self tl_setAnimationDuration:@(duration)];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    UICollectionViewTransitionLayout *transitionLayout = [self startInteractiveTransitionToCollectionViewLayout:layout completion:^(BOOL completed, BOOL finish) {
        UICollectionViewTransitionLayout *transitionLayout = [self tl_transitionLayout];
        if ([transitionLayout conformsToProtocol:@protocol(TLTransitionAnimatorLayout)]) {
            id<TLTransitionAnimatorLayout>layout = (id<TLTransitionAnimatorLayout>)transitionLayout;
            [layout collectionViewDidCompleteTransitioning:self completed:completed finish:finish];
        }
        [self tl_setAnimationDuration:nil];
        [self tl_setTransitionLayout:nil];
        if (completion) {
            completion(completed, finish);
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    [self tl_setTransitionLayout:transitionLayout];
    return transitionLayout;
}

- (void)updateProgress:(CADisplayLink *)link
{
    UICollectionViewLayout *layout = self.collectionViewLayout;
    if ([layout isKindOfClass:[UICollectionViewTransitionLayout class]]) {
        UICollectionViewTransitionLayout *l = (UICollectionViewTransitionLayout *)layout;
        if (l.transitionProgress >= 1) {
            [self finishTransition:link];
        } else {
            NSTimeInterval duration = [[self tl_animationDuration] floatValue];
            CGFloat progress = l.transitionProgress + (link.duration * link.frameInterval) / duration;
            progress = MIN(1, progress);
            l.transitionProgress = progress;
            [l invalidateLayout];
        }
    } else {
        [self finishTransition:link];
    }
}

- (void)finishTransition:(CADisplayLink *)link
{
    [link invalidate];
    [self finishInteractiveTransition];
}

@end
