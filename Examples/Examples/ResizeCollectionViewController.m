//
//  ViewController.m
//  Collection
//
//  Created by Tim Moose on 6/30/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "ResizeCollectionViewController.h"
#import "UIColor+Hex.h"

@interface ResizeCollectionViewController ()
@property (strong, nonatomic) UICollectionViewFlowLayout *smallLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *largeLayout;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) UIColor *sectionHeaderColor;
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
    self.largeLayout.headerReferenceSize = CGSizeMake(50, 50);
    
    [self updateDataModel];
    
    self.colors = @[
          [UIColor colorWithHexRGB:0xBF0C43],
          [UIColor colorWithHexRGB:0xF9BA15],
          [UIColor colorWithHexRGB:0x8EAC00],
          [UIColor colorWithHexRGB:0x127A97],
          [UIColor colorWithHexRGB:0x452B72],
          ];
    self.sectionHeaderColor = [UIColor colorWithWhite:139.f/255.f alpha:1];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)updateDataModel
{
    //set up data model
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (self.showSectionHeaders) {
        for (int section = 0; section < 10; section++) {
            NSString *sectionName = [NSString stringWithFormat:@"Section %d", section];
            for (int i = 0; i < 20; i++) {
                NSString *itemName = [NSString stringWithFormat:@"%d-%d", section, i];
                TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:itemName sectionName:sectionName cellIdentifier:nil data:nil];
                [items addObject:item];
            }
        }
    } else {
        for (int i = 0; i < 200; i++) {
            NSString *itemName = [NSString stringWithFormat:@"%d", i];
            TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:itemName sectionName:nil cellIdentifier:nil data:nil];
            [items addObject:item];
        }
    }
    self.indexPathController.items = items;
}

- (void)setSectionHeaderColor:(UIColor *)sectionHeaderColor
{
    _sectionHeaderColor = sectionHeaderColor;
    [self.collectionView reloadData];
}

- (void)setShowSectionHeaders:(BOOL)showSectionHeaders
{
    if (_showSectionHeaders != showSectionHeaders) {
        _showSectionHeaders = showSectionHeaders;
        [self updateDataModel];
        UIEdgeInsets sectionInset = UIEdgeInsetsZero;
        if (showSectionHeaders) {
            sectionInset.top = 10;
            sectionInset.bottom = 10;
        }
        self.largeLayout.sectionInset = sectionInset;
        self.smallLayout.sectionInset = sectionInset;
        [self.largeLayout invalidateLayout];
        [self.smallLayout invalidateLayout];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.indexPathController.dataModel identifierAtIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.item % [self.colors count]];
    [self updateLabelScale:label cellSize:cell.bounds.size];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        UILabel *label = (UILabel *)[view viewWithTag:1];
        label.text = [self.indexPathController.dataModel sectionNameForSection:indexPath.section];
        view.backgroundColor = self.sectionHeaderColor;
        label.textColor = [UIColor whiteColor];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.showSectionHeaders) {
        return CGSizeMake(50, 50);
    }
    return CGSizeZero;
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
    NSArray *supplementaryKinds = self.showSectionHeaders ? @[UICollectionElementKindSectionHeader] : nil;
    TLTransitionLayout *layout = [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout supplementaryKinds:supplementaryKinds];
    return layout;
}

@end
