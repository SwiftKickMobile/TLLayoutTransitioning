TLLayoutTransitioning
=====================

Components for transitioning between UICollectionView layouts.

##Installation

If you're not using CocoaPods, copy the following files into your project:

    TLTransitionLayout.h
    TLTransitionLayout.m
	UICollectionView+TLTransitionAnimator.h    
	UICollectionView+TLTransitionAnimator.m

##Overview

###TLTransitionLayout Class

A subclass of `UICollectionViewTransitionLayout` that interpolates linearly between
layouts and optionally content offsets. The target offset can be specified directly
by setting the `toContentOffset` property. The `UICollectionView+TLTransitioning` category
provides an API for calculating useful `toContentOffsets` relative to a specified cell or cells: Minimal, Center, Top, Left, Bottom and Right.

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

One noteable feature is the ability to utilize interactive transitioning for animated, non-interactive transitions between layouts. This approach can be a better alternative to `-[UICollectionView setCollectionViewLayout:animated:completion:]` because it is robust and it supports duration, easing curves (courtesy of Warren Moore's [AHEasing library][1]) and all of the `contentOffset` options described above. Check out the [Resize sample project][2]. There are 30 build in easing curves and more can be added by defining custom `AHEasingFunctions`.

The basic animated transition call is as follows:

    TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:toLayout duration:2 easing:QuarticEaseInOut completion:nil];
    CGPoint toOffset = [collectionView toContentOffsetForLayout:layout indexPaths:@[indexPath] placement:TLTransitionLayoutIndexPathPlacementCenter];
    layout.toContentOffset = toOffset;

where the view controller is configured to provide an instance of `TLTransitionLayout` as described above.



##Examples

Open the Examples workspace (not the project) to run the sample app. The following examples are included:

###Resize

The Resize example combines `TLTransitionLayout` and `-[UICollectionView+TLTransitioning transitionToCollectionViewLayout:duration:easing:completion:]` as a better alternative to `-[UICollectionView setCollectionViewLayout:animated:completion]`. Experiment with different durations, easing curves and selected cell destinations on the settings panel.

###Pinch

The Pinch example uses demonstrates a simple pinch-driven interactive transition using `TLTransitionLayout`. The destination `contentOffset` is selected such that the initial visible cells remain centered. Or if a cell is tapped, the `contentOffset` the cell is centered.

[1]:https://github.com/warrenm/AHEasing
[2]:https://github.com/wtmoose/TLLayoutTransitioning/blob/master/Examples/Examples/ResizeCollectionViewController.m
