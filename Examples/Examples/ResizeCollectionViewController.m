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
    self.largeLayout.itemSize = CGSizeMake(self.smallLayout.itemSize.width * 2, self.smallLayout.itemSize.width * 2);
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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayout *toLayout = self.smallLayout == collectionView.collectionViewLayout ? self.largeLayout : self.smallLayout;
    if (self.useTransitionLayout) {
        TLTransitionLayout *layout = (TLTransitionLayout *)[collectionView transitionToCollectionViewLayout:toLayout duration:self.duration completion:nil];
        CGPoint toOffset = [collectionView toContentOffsetForLayout:layout indexPaths:@[indexPath] placement:TLTransitionLayoutIndexPathPlacementCenter];
        layout.toContentOffset = toOffset;
    } else {
        [collectionView setCollectionViewLayout:toLayout animated:YES];
    }
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

@end
