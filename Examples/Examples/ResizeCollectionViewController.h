//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 6/30/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLIndexPathTools.h>
#import <TLLayoutTransitioning/TLLayoutTransitioning.h>
#import <AHEasing/easing.h>

@interface ResizeCollectionViewController : TLCollectionViewController <UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat duration;
@property (nonatomic) AHEasingFunction easingFunction;
@property (nonatomic) TLTransitionLayoutIndexPathPlacement toContentOffset;
@property (nonatomic) BOOL showSectionHeaders;

@end
