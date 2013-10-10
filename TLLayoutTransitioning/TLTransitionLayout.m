//
//  TLTransitionLayout.m
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "TLTransitionLayout.h"

@interface TLTransitionLayout ()
@property (nonatomic) CGPoint fromContentOffset;
@property (strong, nonatomic) NSDictionary *poseAtIndexPath;
@end

@implementation TLTransitionLayout

- (id)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout
{
    if (self = [super initWithCurrentLayout:currentLayout nextLayout:newLayout]) {
        self.fromContentOffset = currentLayout.collectionView.contentOffset;
        self.toContentOffset = currentLayout.collectionView.contentOffset;
        [self calculateLayout];
    }
    return self;
}

- (void) setTransitionProgress:(CGFloat)transitionProgress
{
    super.transitionProgress = transitionProgress;
    CGFloat t = self.transitionProgress;
    CGFloat f = 1 - t;
    CGPoint offset = CGPointMake(f * self.fromContentOffset.x + t * self.toContentOffset.x, f * self.fromContentOffset.y + t * self.toContentOffset.y);
    self.collectionView.contentOffset = offset;
    if (self.progressChanged) {
        self.progressChanged(transitionProgress);
    }
}

#pragma mark - Layout logic

- (void)calculateLayout
{
    CGFloat t = self.transitionProgress;
    CGFloat f = 1 - t;
    
    NSMutableDictionary *poses = [NSMutableDictionary dictionary];
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *fromPose = [self.currentLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *toPose = [self.nextLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *pose = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat originX = f * fromPose.frame.origin.x + t * toPose.frame.origin.x;
            CGFloat originY = f * fromPose.frame.origin.y + t * toPose.frame.origin.y;
            CGFloat sizeWidth = f * fromPose.frame.size.width + t * toPose.frame.size.width;
            CGFloat sizeHeight = f * fromPose.frame.size.height + t * toPose.frame.size.height;
            pose.frame = CGRectMake(originX, originY, sizeWidth, sizeHeight);
            
            pose.alpha = f * fromPose.alpha + t * toPose.alpha;
            
            if (self.updateLayoutAttributes) {
                UICollectionViewLayoutAttributes *updatedPose = self.updateLayoutAttributes(pose);
                if (updatedPose) {
                    pose = updatedPose;
                }
            }
            
            [poses setObject:pose forKey:[self keyForIndexPath:pose.indexPath]];
        }
    }
    self.poseAtIndexPath = poses;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *poses = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *pose = [self.poseAtIndexPath objectForKey:indexPath];
            CGRect intersection = CGRectIntersection(rect, pose.frame);
            if (!CGRectIsEmpty(intersection)) {
                [poses addObject:pose];
            }
        }
    }
    return poses;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.poseAtIndexPath objectForKey:indexPath];
}

- (void)invalidateLayout
{
    [self calculateLayout];
    [super invalidateLayout];
}

/*
 Must generate a key for index path because `[NSIndexPath isEqual] is not reliable
 under iOS7 (I think because `UITableView` sometimes uses `NSIndexPath` and other times `UIMutableIndexPath`
 */
- (NSIndexPath *)keyForIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath class] == [NSIndexPath class]) {
        return indexPath;
    }
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
}

#pragma mark - Key index path

- (void)setKeyIndexPath:(NSIndexPath *)keyIndexPath
{
    if (_keyIndexPath != keyIndexPath) {
        _keyIndexPath = keyIndexPath;
        [self updateToContentOffset];
        [self invalidateLayout];
    }
}

- (void)setKeyIndexPathPlacement:(TLTransitionLayoutKeyIndexPathPlacement)keyIndexPathPlacement
{
    if (_keyIndexPathPlacement != keyIndexPathPlacement) {
        _keyIndexPathPlacement = keyIndexPathPlacement;
        [self updateToContentOffset];
        [self invalidateLayout];
    }
}

- (void)setToContentOffset:(CGPoint)toContentOffset
{
    if (!CGPointEqualToPoint(_toContentOffset, toContentOffset)) {
        _toContentOffset = toContentOffset;
        [self invalidateLayout];
    }
}

- (void)updateToContentOffset
{
    if (self.keyIndexPath) {
        
//        UICollectionViewLayoutAttributes *fromPose = [self.nextLayout layoutAttributesForItemAtIndexPath:self.keyIndexPath];
        UICollectionViewLayoutAttributes *toPose = [self.nextLayout layoutAttributesForItemAtIndexPath:self.keyIndexPath];
        
        switch (self.keyIndexPathPlacement) {
            case TLTransitionLayoutKeyIndexPathPlacementNone:
            {
            
            }
                break;
            case TLTransitionLayoutKeyIndexPathPlacementCenter:
            {
            
            CGSize contentSize = self.nextLayout.collectionViewContentSize;
            CGRect bounds = self.collectionView.bounds;
            bounds.origin.x = 0;
            bounds.origin.y = 0;
            UIEdgeInsets inset = self.collectionView.contentInset;
            
            CGPoint insetOffset = CGPointMake(inset.left, inset.top);
            CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
            CGPoint keyCenter = CGPointMake(CGRectGetMidX(toPose.frame), CGRectGetMidY(toPose.frame));
            
            CGPoint offset = CGPointMake(insetOffset.x + keyCenter.x - boundsCenter.x, insetOffset.y + keyCenter.y - boundsCenter.y);
            
            CGFloat maxOffsetX = inset.left + inset.right + contentSize.width - bounds.size.width;
            CGFloat maxOffsetY = inset.top + inset.right + contentSize.height - bounds.size.height;
            
            offset.x = MAX(0, offset.x);
            offset.y = MAX(0, offset.y);

            offset.x = MIN(maxOffsetX, offset.x);
            offset.y = MIN(maxOffsetY, offset.y);

            self.toContentOffset = offset;
            
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - TLTransitionAnimatorLayout

- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView completed:(BOOL)completed finish:(BOOL)finish
{
    if (finish) {
        collectionView.contentOffset = self.toContentOffset;
    }
}

@end
