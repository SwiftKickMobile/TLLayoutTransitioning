TLLayoutTransitioning
=====================

Components for transitioning between UICollectionView layouts.

##Installation

Copy the following files into your project:

    TLTransitionLayout.h
    TLTransitionLayout.m
	UICollectionView+TLTransitionAnimator.h    
	UICollectionView+TLTransitionAnimator.m

##Overview

###TLTransitionLayout Class

A subclass of `UICollectionViewTransitionLayout` that supports content offset change. The target offset can be specified directly by setting the `toContentOffset` property or indirectly by setting the `keyIndexPath`. The later method is useful for controlling the final position of a specific item, typically a selected item (currently, the key item is positioned as close to the center as possible). 

The basic usage is as follows:

```Objective-C
- (void)someViewControllerEventHandler
{
    UICollectionViewLayout *nextLayout = ...;
    self.transitionLayout = (TLTransitionLayout *)[self.collectionView startInteractiveTransitionToCollectionViewLayout:nextLayout 
                                        completion:^(BOOL completed, BOOL finish) {
	    if (finish) {
            self.collectionView.contentOffset = self.transitionLayout.toContentOffset;
            self.transitionLayout = nil;
	    }
    }];
    self.transitionLayout.keyIndexPath = indexPath;
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

```

Note that the collection view will reset the `contentOffset` after the transition is finalized, but this can be negated by setting it back to `toContentOffset` in the completion block.

###UICollectionView+TLTransitionAnimator Category

A category on `UICollectionView` that can perform an interactive transition as a non-interactive animation with a specified duration. This can be used as an alternative to `setCollectionViewLayout:animated:completion`, together with a custom `UICollectionViewTransitionLayout` class, when finer-grained control of the transition is needed.

The basic usage combined with `TLTransitionLayout` is as follows:

```Objective-C
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayout *nextLayout = ...;
    TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:otherLayout duration:self.duration completion:nil];
        layout.keyIndexPath = indexPath;
}
```

Note that in the "TLTransitionLayout Class" section, it was necessary to set the final `contentOffset` of the collection view in the transition completion block. We don't need to do that here because `TLTransitionLayout` implements the `TLTransitionAnimatorLayout` protocol, allowing `TLTransitionLayout` to receive the `collectionViewDidCompleteTransitioning` callback from `TLTransitionAnimator`, where it sets the final `contentOffset` internally.

If your own custom transition layouts need to do any final cleanup (such as setting the final `contentOffset`) they can do so by implementing the `TLTransitionAnimatorLayout` protocol.

##Examples

###Resize

The Resize project combines `TLTransitionLayout` and `UICollectionView+TLTransitionAnimator` to improve on the behavior of `setCollectionViewLayout:animated:completion`. A switch is provided to toggle between the two techniques to illustrate the improvement.