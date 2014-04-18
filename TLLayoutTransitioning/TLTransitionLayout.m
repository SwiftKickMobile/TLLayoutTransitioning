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
@property (strong, nonatomic) NSDictionary *poses;
@property (nonatomic) CGFloat previousProgress;
@property (strong, nonatomic) NSArray *supplementaryKinds;
@end

@implementation TLTransitionLayout

- (id)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout
{
    if (self = [super initWithCurrentLayout:currentLayout nextLayout:newLayout]) {
        _fromContentOffset = currentLayout.collectionView.contentOffset;
    }
    return self;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress time:(CGFloat)time
{
//    NSLog(@"setTransitionProgress=%f, time=%f", transitionProgress, time);
    if (self.transitionProgress != transitionProgress) {
        self.previousProgress = self.transitionProgress;
        super.transitionProgress = transitionProgress;
        // enforce time range of 0 to 1
        // TODO since time is a user-supplied value, we might want to emit a
        // warning if time goes out-of-bounds
        _transitionTime = MAX(0, MIN(1, time));
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
}

- (void) setTransitionProgress:(CGFloat)transitionProgress
{
    [self setTransitionProgress:transitionProgress time:transitionProgress];
}

#pragma mark - Layout logic

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.cancelledInPlace) {
        return;
    };

    BOOL reverse = self.previousProgress > self.transitionProgress;
    
    CGFloat remaining = reverse ? self.previousProgress : 1 - self.previousProgress;
    CGFloat t = remaining == 0 ? self.transitionProgress : fabs(self.transitionProgress - self.previousProgress) / remaining;
    CGFloat f = 1 - t;
    
    NSMutableDictionary *poses = [NSMutableDictionary dictionary];
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        // cells
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSIndexPath *key = [self keyForIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *fromPose = self.poses
                    ? [self.poses objectForKey:key]
                    : [self.currentLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *toPose = reverse
                    ? [self.currentLayout layoutAttributesForItemAtIndexPath:indexPath]
                    : [self.nextLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *pose = [[[self class] layoutAttributesClass]
                                                      layoutAttributesForCellWithIndexPath:indexPath];
            
            [self interpolatePose:pose fromPose:fromPose toPose:toPose fromProgress:f toProgress:t];
            
            if (self.updateLayoutAttributes) {
                UICollectionViewLayoutAttributes *fromPose = [self.currentLayout layoutAttributesForItemAtIndexPath:indexPath];
                UICollectionViewLayoutAttributes *toPose = [self.nextLayout layoutAttributesForItemAtIndexPath:indexPath];
                UICollectionViewLayoutAttributes *updatedPose = self.updateLayoutAttributes(pose, fromPose, toPose, self.transitionProgress);
                if (updatedPose) {
                    pose = updatedPose;
                }
            }
            
            [poses setObject:pose forKey:key];
        }
        // supplementary views
        for (NSString *kind in self.supplementaryKinds) {

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSString *key = [self keyForIndexPath:indexPath kind:kind];
            
            UICollectionViewLayoutAttributes *fromPose = self.poses
                    ? [self.poses objectForKey:key]
                    : [self.currentLayout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
            UICollectionViewLayoutAttributes *toPose = reverse
                    ? [self.currentLayout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath]
                    : [self.nextLayout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
            UICollectionViewLayoutAttributes *pose = [[[self class] layoutAttributesClass]
                                                      layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
            
            [self interpolatePose:pose fromPose:fromPose toPose:toPose fromProgress:f toProgress:t];
            
            // TODO need to incorporate the `updateLayoutAttributes` callback
            
            [poses setObject:pose forKey:key];
        }
    }
    self.poses = poses;
}

- (void)interpolatePose:(UICollectionViewLayoutAttributes *)pose fromPose:(UICollectionViewLayoutAttributes *)fromPose toPose:(UICollectionViewLayoutAttributes *)toPose fromProgress:(CGFloat)f toProgress:(CGFloat)t
{
    CGRect frame = CGRectZero;
    frame.origin.x = f * fromPose.frame.origin.x + t * toPose.frame.origin.x;
    frame.origin.y = f * fromPose.frame.origin.y + t * toPose.frame.origin.y;
    frame.size.width = f * fromPose.frame.size.width + t * toPose.frame.size.width;
    frame.size.height = f * fromPose.frame.size.height + t * toPose.frame.size.height;
    pose.frame = frame;
    
    pose.alpha = f * fromPose.alpha + t * toPose.alpha;

    // TODO need to interpolate tranforms
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *poses = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        // cells
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *pose = [self.poses objectForKey:indexPath];
            CGRect intersection = CGRectIntersection(rect, pose.frame);
            if (!CGRectIsEmpty(intersection)) {
                [poses addObject:pose];
            }
        }
        // supplementary views
        for (NSString *kind in self.supplementaryKinds) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            id key = [self keyForIndexPath:indexPath kind:kind];
            UICollectionViewLayoutAttributes *pose = [self.poses objectForKey:key];
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
    id key = [self keyForIndexPath:indexPath];
    return [self.poses objectForKey:key];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    id key = [self keyForIndexPath:indexPath kind:kind];
    UICollectionViewLayoutAttributes *pose = [self.poses objectForKey:key];
    return pose;
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

- (id)keyForIndexPath:(NSIndexPath *)indexPath kind:(NSString *)kind
{
    NSString *key = [NSString stringWithFormat:@"%ld-%ld-%@", indexPath.section, indexPath.item, kind];
    return key;
}

- (void)setToContentOffset:(CGPoint)toContentOffset
{
    self.toContentOffsetInitialized = YES;
    if (!CGPointEqualToPoint(_toContentOffset, toContentOffset)) {
        _toContentOffset = toContentOffset;
        [self invalidateLayout];
    }
}

#pragma mark - Cancelling in place

- (void)cancelInPlace
{
    _cancelledInPlace = YES;
}

#pragma mark - TLTransitionAnimatorLayout

- (void)collectionViewDidCompleteTransitioning:(UICollectionView *)collectionView completed:(BOOL)completed finish:(BOOL)finish
{
    if (finish && self.toContentOffsetInitialized) {
        collectionView.contentOffset = self.toContentOffset;
    }
}

#pragma mark - Creating layouts

- (id)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout supplementaryKinds:(NSArray *)supplementaryKinds
{
    if (self = [self initWithCurrentLayout:currentLayout nextLayout:newLayout]) {
        _supplementaryKinds = supplementaryKinds;
    }
    return self;
}

@end
