//
//  ViewController.m
//  Collection
//
//  Created by Tim Moose on 6/30/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "ResizeCollectionViewController.h"
#import <TLLayoutTransitioning/TLTransitionLayout.h>
#import <TLLayoutTransitioning/UICollectionView+TLTransitioning.h>
#import "UIColor+Hex.h"

@interface ResizeCollectionViewController ()
@property (strong, nonatomic) UICollectionViewFlowLayout *smallLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *largeLayout;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *transitionIndexPaths;
@end

@implementation ResizeCollectionViewController

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
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.item % [self.colors count]];
    [self updateLabelScale:label cellSize:cell.bounds.size];
    return cell;
}

- (void)updateLabelScale:(UILabel *)label cellSize:(CGSize)cellSize
{
    // update the label's font size as a proportion of the cell's width and
    // let Auto Layout adjust the label's frame based on the intrinsic content size
    CGFloat pointSize = cellSize.width * 17 / 128.f;
    label.font = [UIFont fontWithName:label.font.fontName size:pointSize];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayout *toLayout = self.smallLayout == collectionView.collectionViewLayout
            ? self.largeLayout
            : self.smallLayout;
    self.transitionIndexPaths = @[indexPath];
    TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:toLayout
                                                                                               duration:self.duration
                                                                                                 easing:self.easingFunction
                                                                                             completion:nil];
    CGPoint toOffset = [collectionView toContentOffsetForLayout:layout
                                                     indexPaths:self.transitionIndexPaths
                                                      placement:self.toContentOffset
                                                placementAnchor:kTLPlacementAnchorDefault
                                                 placementInset:UIEdgeInsetsZero
                                                         toSize:self.collectionView.bounds.size
                                                 toContentInset:self.collectionView.contentInset];
    layout.toContentOffset = toOffset;
    __weak ResizeCollectionViewController *weakSelf = self;
    [layout setUpdateLayoutAttributes:^UICollectionViewLayoutAttributes *(UICollectionViewLayoutAttributes *pose, UICollectionViewLayoutAttributes *fromPose, UICollectionViewLayoutAttributes *toPose, CGFloat progress) {
        CGSize cellSize = pose.bounds.size;
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:pose.indexPath];
        if (cell) {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            [weakSelf updateLabelScale:label cellSize:cellSize];
        }
        return nil;
    }];
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    TLTransitionLayout *layout = [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return layout;
}

@end
