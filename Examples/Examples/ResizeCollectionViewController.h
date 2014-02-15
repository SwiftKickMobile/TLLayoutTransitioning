//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 6/30/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLCollectionViewController.h>
#import <TLLayoutTransitioning/UICollectionView+TLTransitioning.h>
#import "easing.h"

@interface ResizeCollectionViewController : TLCollectionViewController
@property (nonatomic) CGFloat duration;
@property (nonatomic) AHEasingFunction easingFunction;
@property (nonatomic) TLTransitionLayoutIndexPathPlacement toContentOffset;
@end
