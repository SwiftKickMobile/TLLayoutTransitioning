//
//  ViewController.m
//  Collection
//
//  Created by Tim Moose on 6/30/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "PinchCollectionViewController.h"
#import <TLLayoutTransitioning/TLLayoutTransitioning.h>
#import "UIColor+Hex.h"
#import <QuartzCore/QuartzCore.h>

@interface PinchCollectionViewController ()
@property (strong, nonatomic) UICollectionViewFlowLayout *smallLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *largeLayout;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) TLTransitionLayout *transitionLayout;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;
@property (nonatomic) CGFloat initialScale;
@property (nonatomic) BOOL isLayoutInTransition;
@end

static const CGFloat kLargeLayoutScale = 2.5;

@implementation PinchCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //stash small layout from storyboard
    self.smallLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    //create large layout
    self.largeLayout = [[UICollectionViewFlowLayout alloc] init];
    self.largeLayout.scrollDirection = self.smallLayout.scrollDirection;
    self.largeLayout.minimumLineSpacing = self.smallLayout.minimumLineSpacing;
    self.largeLayout.minimumInteritemSpacing = self.smallLayout.minimumInteritemSpacing;
    self.largeLayout.itemSize = CGSizeMake(336, 336);
    self.largeLayout.sectionInset = self.smallLayout.sectionInset;
    
    //set up data model
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i = 0; i < 200; i++) {
        [items addObject:[NSString stringWithFormat:@"%d", i]];
    }
    self.indexPathController.items = items;
    
    self.colors = @[
                    [UIColor colorWithHexRGB:0xBF0C43],
                    [UIColor colorWithHexRGB:0xF9BA15],
                    [UIColor colorWithHexRGB:0x8EAC00],
                    [UIColor colorWithHexRGB:0x127A97],
                    [UIColor colorWithHexRGB:0x452B72],
                    ];
    
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:self.pinch];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    if (self.isLayoutInTransition) {
        return;
    }
    
    if (pinch.state == UIGestureRecognizerStateBegan && !self.transitionLayout) {
        
        // remember initial scale factor for progress calculation
        self.initialScale = pinch.scale;
        
        UICollectionViewLayout *toLayout = self.smallLayout == self.collectionView.collectionViewLayout ? self.largeLayout : self.smallLayout;
        
//        NSLog(@"will begin transition; pinch: %@", pinch);
        self.transitionLayout = (TLTransitionLayout *)[self.collectionView startInteractiveTransitionToCollectionViewLayout:toLayout completion:^(BOOL completed, BOOL finish) {
            if (finish) {
//                NSLog(@"did finish");
                self.collectionView.contentOffset = self.transitionLayout.toContentOffset;
            } else {
//                NSLog(@"did cancel");
                self.collectionView.contentOffset = self.transitionLayout.fromContentOffset;
            }
            self.transitionLayout = nil;
            self.isLayoutInTransition = NO;
        }];
        
        NSArray *visiblePoses = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:self.collectionView.bounds];
        NSMutableArray *visibleIndexPaths = [NSMutableArray arrayWithCapacity:visiblePoses.count];
        for (UICollectionViewLayoutAttributes *pose in visiblePoses) {
            [visibleIndexPaths addObject:pose.indexPath];
        }
        self.transitionLayout.toContentOffset = [self.collectionView toContentOffsetForLayout:self.transitionLayout indexPaths:visibleIndexPaths placement:TLTransitionLayoutIndexPathPlacementCenter];
        
    }
    
    else if (pinch.state == UIGestureRecognizerStateChanged && self.transitionLayout && pinch.numberOfTouches > 1) {
        
        CGFloat finalScale = self.transitionLayout.nextLayout == self.largeLayout ? kLargeLayoutScale : 1 / kLargeLayoutScale;
        self.transitionLayout.transitionProgress = transitionProgress(self.initialScale, pinch.scale, finalScale, nil);
        
    }
    
    else if ((pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) && self.transitionLayout) {
        self.isLayoutInTransition = YES;
        if (self.transitionLayout.transitionProgress > 0.5) {
//            NSLog(@"will finish; pinch: %@", pinch);
            [self.collectionView finishInteractiveTransition];
        } else {
//            NSLog(@"will cancel; pinch: %@", pinch);
            [self.collectionView cancelInteractiveTransition];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.item % [self.colors count]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UICollectionViewLayout *toLayout = self.smallLayout == self.collectionView.collectionViewLayout ? self.largeLayout : self.smallLayout;
    self.transitionLayout = (TLTransitionLayout *)[self.collectionView startInteractiveTransitionToCollectionViewLayout:toLayout completion:^(BOOL completed, BOOL finish) {
        self.collectionView.contentOffset = self.transitionLayout.toContentOffset;
        self.transitionLayout = nil;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    self.transitionLayout.toContentOffset = [self.collectionView toContentOffsetForLayout:self.transitionLayout indexPaths:@[indexPath] placement:TLTransitionLayoutIndexPathPlacementCenter];
    [collectionView finishInteractiveTransition];
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

@end
