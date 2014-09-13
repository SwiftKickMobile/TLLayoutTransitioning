TLLayoutTransitioning
=====================

Enhanced transitioning between UICollectionView layouts in iOS.

##Overview

TLLayoutTransitioning provides a `TLLayoutTransition` transition layout subclass and a `UICollectionView+TLTransitioning` category that combine to solve a few problems with collection view layout transitioning:

1. `UICollectionViewLayoutTransition` does not handle content offset well, often leaving cells where you don't want them. `TLTransitionLayout` provides elegant control of content offset with Minimal, Visible, Center, Top, Left, Bottom or Right placement options relative to one or more index paths.

2. `UICollectionViewLayoutTransition` does not support supplementary views. `TLTransitionLayout` provides support for any supplementary view kinds specified in the initializer.

3. `-[UICollectionView setCollectionViewLayout:animated:completion]` has [serious known bugs][3] in iOS7 and does not provide any animation options. TLLayoutTransitioning provides a robust alternative to this API with support for animation duration, 30+ easing curves and content offset control. This is done by using `CADisplayLink` to drive an interactive `TLTransitionLayout` as a non-interactive animation.

Check out the demos in the Examples workspace!

###TLTransitionLayout Class

`TLTransitionLayout` is a subclass of `UICollectionViewTransitionLayout` that interpolates linearly between layouts and optionally between the current content offset and a specified final offset. 

The final offset is specified
by setting the `toContentOffset` property. The `UICollectionView+TLTransitioning` category
provides an API for calculating Minimal, Visible, Center, Top, Left, Bottom or Right offset placements relative to one or more index paths. 

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
    NSArray *supplementaryKinds = ...; // optional supplementary view kinds
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout supplementaryKinds:supplementaryKinds];
}

```

Note that the collection view will reset `contentOffset` after the transition is finalized, but as illustrated above, this can be negated by setting it back to `toContentOffset` in the completion block.

####Canceling a Transition

If you want to stop the current transition to start a new one from the current position, you need a way to stop the current transition in-place. Apple provides `finishInteractiveTransition` and `cancelInteractiveTransition` to end a transition, but neither of these stops the transition in-place. So, TLLayoutTransitioning provides such a method:

```Objective-C
[self.collectionView cancelInteractiveTransitionInPlaceWithCompletion:^(){
    // initiate new transition in the completion block
}];
```

###UICollectionView+TLTransitioning Category

The `UICollectionView+TLTransitioning` category provides some of useful methods for calculating for interactive transitions. In particular, the `toContentOffsetForLayout:indexPaths:placement` API calculates final content offset values to achieve Minimal, Visible, Center, Top, Left, Bottom or Right placements for one or more index paths. The expanded version of this API provides for even further fine-tuning and supports transitioning to a different collection view size and content inset:

````
- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
                    placementAnchor:(CGPoint)placementAnchor
                     placementInset:(UIEdgeInsets)placementInset
                             toSize:(CGSize)toSize
                     toContentInset:(UIEdgeInsets)toContentInset
````

`UICollectionView+TLTransitioning` also provides an alternative to `-[UICollectionView setCollectionViewLayout:animated:completion]` for non-interactive animation between layouts with support for animation duration, 30 built-in easing curves (courtesy of Warren Moore's [AHEasing library][1]), user defined easing curves (by defining custom `AHEasingFunctions`) and content offset control. The basic transition call is as follows:

```Objective-C
TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:toLayout duration:2 easing:QuarticEaseInOut completion:nil];
CGPoint toOffset = [collectionView toContentOffsetForLayout:layout indexPaths:@[indexPath] placement:TLTransitionLayoutIndexPathPlacementCenter];
layout.toContentOffset = toOffset;
```

where the view controller is configured to provide an instance of `TLTransitionLayout` as described above. Check out the [Resize sample project][2] in the Examples workspace to see this in action. 

##Installation

If you're not using CocoaPods, copy the following files into your project:

    TLTransitionLayout.h
    TLTransitionLayout.m
	UICollectionView+TLTransitionAnimator.h    
	UICollectionView+TLTransitionAnimator.m
	
As well as the following files from [AHEasing][4]:

	easing.h
	easing.c

##Examples

Open the Examples workspace (not the project) to run the sample app. The following examples are included:

###Resize

The Resize example combines `TLTransitionLayout` and `-[UICollectionView+TLTransitioning transitionToCollectionViewLayout:duration:easing:completion:]` as a better alternative to `-[UICollectionView setCollectionViewLayout:animated:completion]`. Experiment with different durations, easing curves and content offset options on the settings panel. Toggle "show section headers" to see transitioning supplementary views.

###Pinch

The Pinch example uses demonstrates a simple pinch-driven interactive transition using `TLTransitionLayout`. The destination `contentOffset` is selected such that the initial visible cells remain centered. Or if a cell is tapped, the `contentOffset` the cell is centered.

[1]:https://github.com/warrenm/AHEasing
[2]:https://github.com/wtmoose/TLLayoutTransitioning/blob/master/Examples/Examples/ResizeCollectionViewController.m
[3]:http://stackoverflow.com/questions/13780138/dynamically-setting-layout-on-uicollectionview-causes-inexplicable-contentoffset
[4]:https://github.com/warrenm/AHEasing