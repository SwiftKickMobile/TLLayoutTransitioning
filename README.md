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

A subclass of `UICollectionViewTransitionLayout` that interpolates linearly between
layouts and optionally content offsets. The target offset can be specified directly
by setting the `toContentOffset` property. The `UICollectionView+TLTransitioning` category
provides API for calculating useful values for `toContentOffset`.

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
    NSArray *indexPaths = ...;// some selection of index paths to place
    self.transitionLayout.toContentOffset = [self.collectionView toContentOffsetForLayout:self.transitionLayout indexPaths:indexPaths placement:TLTransitionLayoutIndexPathPlacementCenter];
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

```

Note that the collection view will reset the `contentOffset` after the transition is finalized, but this can be negated by setting it back to `toContentOffset` in the completion block.

###UICollectionView+TLTransitioning Category

A category on `UICollectionView` that provides a variety of utility methods and calculations
for interactive transitioning.

##Examples

###Pinch

THe Pinch project uses demonstrates using a pinch gesture recognizer to drive an interactive transition using `TLTransitionLayout`. The final content offset is selected such that the initial cells visible on screen remain centered on screen. Or if a cell is tapped, the final content offset is selected such that the selected cell is centered.

###Resize

The Resize project combines `TLTransitionLayout` and `[UICollectionView+TLTransitioning transitionToCollectionViewLayout:duration:completion:]` to improve on the behavior of `setCollectionViewLayout:animated:completion`. A switch is provided for toggling between the two techniques to illustrate the improvement.