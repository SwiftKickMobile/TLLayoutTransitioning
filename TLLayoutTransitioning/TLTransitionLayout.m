//
//  TLTransitionLayout.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLTransitionLayout.h"

@interface TLTransitionLayout ()
@property (nonatomic) BOOL toContentOffsetInitialized;
@property (nonatomic) CGPoint fromContentOffset;
@end

@implementation TLTransitionLayout

- (id)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout
{
    if (self = [super initWithCurrentLayout:currentLayout nextLayout:newLayout]) {
        self.fromContentOffset = currentLayout.collectionView.contentOffset;
    }
    return self;
}

- (void) setTransitionProgress:(CGFloat)transitionProgress
{
    super.transitionProgress = transitionProgress;
    if (self.toContentOffsetInitialized) {
        CGFloat t = self.transitionProgress;
        CGFloat f = 1 - t;
        CGPoint offset = CGPointMake(f * self.fromContentOffset.x + t * self.toContentOffset.x, f * self.fromContentOffset.y + t * self.toContentOffset.y);
        self.collectionView.contentOffset = offset;
        if (self.progressChanged) {
            self.progressChanged(transitionProgress);
        }
    }
}

#pragma mark - Layout logic

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *poses = [super layoutAttributesForElementsInRect:rect];
    if (self.updateLayoutAttributes) {
        NSMutableArray *updatedPoses = [NSMutableArray arrayWithCapacity:poses.count];
        for (UICollectionViewLayoutAttributes *pose in poses) {
            UICollectionViewLayoutAttributes *updatedPose = self.updateLayoutAttributes(pose);
            [updatedPoses addObject:updatedPose ? updatedPose : pose];
        }
    }
    return poses;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *pose = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (self.updateLayoutAttributes) {
        UICollectionViewLayoutAttributes *updatedPose = self.updateLayoutAttributes(pose);
        if (updatedPose) {
            pose = updatedPose;
        }
    }
    return pose;
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
    self.toContentOffsetInitialized = YES;
    if (!CGPointEqualToPoint(_toContentOffset, toContentOffset)) {
        _toContentOffset = toContentOffset;
        NSLog(@"toContentOffset=%@", NSStringFromCGPoint(toContentOffset));
        [self invalidateLayout];
    }
}

- (void)updateToContentOffset
{
    if (self.keyIndexPath) {
        
        UICollectionViewLayoutAttributes *toPose = [self.nextLayout layoutAttributesForItemAtIndexPath:self.keyIndexPath];
        
        switch (self.keyIndexPathPlacement) {
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
    if (finish && self.toContentOffsetInitialized) {
        collectionView.contentOffset = self.toContentOffset;
    }
}

@end
