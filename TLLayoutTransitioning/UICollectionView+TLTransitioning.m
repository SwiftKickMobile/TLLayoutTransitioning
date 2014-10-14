//
//  UICollectionView+TransitionLayoutAnimator.m
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

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "UICollectionView+TLTransitioning.h"
#import "TLTransitionLayout.h"

CGPoint kTLPlacementAnchorDefault = (CGPoint){CGFLOAT_MAX, CGFLOAT_MAX};

@interface TLCancelLayout : UICollectionViewLayout
@property (nonatomic) CGPoint contentOffset;
- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
@end

@implementation UICollectionView (TLTransitioning)

#pragma mark - Simulated properties

static char kTLTransitionDataKey;
static char kTLEasingFunctionKey;

- (NSMutableDictionary *)tl_transitionData
{
    return objc_getAssociatedObject(self, &kTLTransitionDataKey);
}

- (void)tl_setTransitionData:(NSMutableDictionary *)data
{
    objc_setAssociatedObject(self, &kTLTransitionDataKey, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AHEasingFunction)tl_easingFunction
{
    NSValue *value = objc_getAssociatedObject(self, &kTLEasingFunctionKey);
    return [value pointerValue];
}

- (void)tl_setEasingFunction:(AHEasingFunction)easingFunction
{
    NSValue *value = easingFunction ? [NSValue valueWithPointer:easingFunction] : nil;
    objc_setAssociatedObject(self, &kTLEasingFunctionKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Transition logic

- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout duration:(NSTimeInterval)duration easing:(AHEasingFunction)easingFunction completion:(UICollectionViewLayoutInteractiveTransitionCompletion)completion
{
    // TODO Automatically cancel in-flight transition?
    if (duration <= 0) {
        [NSException raise:@"" format:@""];//TODO
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:10];
    data[@"duration"] = @(duration);
    data[@"startTime"] = @(CACurrentMediaTime());
    [self tl_setEasingFunction:easingFunction];
    [self tl_setTransitionData:data];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    __weak UICollectionView *weakSelf = self;
    UICollectionViewTransitionLayout *transitionLayout = [self startInteractiveTransitionToCollectionViewLayout:layout completion:^(BOOL completed, BOOL finish) {
        __strong UICollectionView *strongSelf = weakSelf;
        NSMutableDictionary *data = [strongSelf tl_transitionData];
        UICollectionViewTransitionLayout *transitionLayout = data[@"transitionLayout"];
        if ([transitionLayout conformsToProtocol:@protocol(TLTransitionAnimatorLayout)]) {
            id<TLTransitionAnimatorLayout>layout = (id<TLTransitionAnimatorLayout>)transitionLayout;
            [layout collectionViewDidCompleteTransitioning:strongSelf completed:completed finish:finish];
        }
        [strongSelf tl_setTransitionData:nil];
        [strongSelf tl_setEasingFunction:nil];
        if (completion) {
            completion(completed, finish);
        }
        TLCancelLayout *cancelLayout = data[@"cancelLayout"];
        if (cancelLayout) {
            self.collectionViewLayout = cancelLayout;
            self.contentOffset = cancelLayout.contentOffset;
        }
        void(^cancelCompletion)() = data[@"cancelCompletion"];
        if (cancelCompletion) {
            cancelCompletion();
        }
    }];
    data[@"transitionLayout"] = transitionLayout;
    data[@"link"] = link;
    return transitionLayout;
}

- (BOOL)isInteractiveTransitionInProgress
{
    return [self tl_transitionData] != nil;
}

- (BOOL)isInteractiveTransitionFinalizing
{
    if ([self isInteractiveTransitionInProgress]) {
        NSMutableDictionary *data = [self tl_transitionData];
        return data[@"link"] == nil;
    }
    return NO;
}

- (UICollectionViewTransitionLayout *)transitionToCollectionViewLayout:(UICollectionViewLayout *)layout
                                                              duration:(NSTimeInterval)duration
                                                            completion:(UICollectionViewLayoutInteractiveTransitionCompletion)completion
{
    return [self transitionToCollectionViewLayout:layout duration:duration
                                           easing:nil completion:completion];
}

- (void)updateProgress:(CADisplayLink *)link
{
    NSMutableDictionary *data = [self tl_transitionData];
    UICollectionViewLayout *layout = self.collectionViewLayout;
    if ([layout isKindOfClass:[UICollectionViewTransitionLayout class]]) {
        CFTimeInterval startTime = [data[@"startTime"] floatValue];
        NSTimeInterval duration = [data[@"duration"] floatValue];
        CFTimeInterval time = duration > 0 ? (link.timestamp - startTime) / duration : 1;
        time = MIN(1, time);
        time = MAX(0, time);
        AHEasingFunction easingFunction = [self tl_easingFunction];
        CGFloat progress = easingFunction ? easingFunction(time) : time;
        id l = layout;
        if ([l respondsToSelector:@selector(setTransitionProgress:time:)]) {
            [l setTransitionProgress:progress time:time];
        } else {
            [l setTransitionProgress:progress];
        }
        [l invalidateLayout];
        if (time >= 1) {
            [self finishTransition:link];
        }
    } else {
        [self finishTransition:link];
    }
}

- (void)finishTransition:(CADisplayLink *)link
{
    [link invalidate];
    NSMutableDictionary *data = [self tl_transitionData];
    // remove link from transition data as a signal that the transition is finalizing
    [data removeObjectForKey:@"link"];
    [self finishInteractiveTransition];
}

- (void)cancelInteractiveTransitionInPlaceWithCompletion:(void (^)())completion
{
    NSMutableDictionary *data = [self tl_transitionData];
    CADisplayLink *link = data[@"link"];
    UICollectionViewLayout *layout = self.collectionViewLayout;
    if (completion) {
        data[@"cancelCompletion"] = completion;
    }
    if ([self isInteractiveTransitionInProgress] && ![self isInteractiveTransitionFinalizing]) {
        id transitionLayout = layout;
        if ([transitionLayout respondsToSelector:@selector(cancelInPlace)]) {
            id t = transitionLayout;
            // must call prepareLayout before cancelling because progress has been
            // udpated at this point but prepareLayout has not been called
            [t prepareLayout];
            [t cancelInPlace];
        }
        TLCancelLayout *cancelLayout = [[TLCancelLayout alloc] initWithLayout:transitionLayout];
        data[@"cancelLayout"] = cancelLayout;
        if ([transitionLayout respondsToSelector:@selector(setTransitionProgress:time:)]) {
            [transitionLayout setTransitionProgress:0.f time:0.f];
        } else {
            [transitionLayout setTransitionProgress:0.f];
        }
        self.contentOffset = cancelLayout.contentOffset;
        [transitionLayout invalidateLayout];
        [link invalidate];
        // remove link from transition data as a signal that the transition is finalizing
        [data removeObjectForKey:@"link"];
        [self cancelInteractiveTransition];
    }
}

#pragma mark - Calculating transition values

CGFloat transitionProgress(CGFloat initialValue, CGFloat currentValue,
                           CGFloat finalValue, AHEasingFunction easingFunction)
{
    CGFloat p = (currentValue - initialValue) / (finalValue - initialValue);
    p = MIN(1.0, p);
    p = MAX(0, p);
    return easingFunction ? easingFunction(p) : p;
}

- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
{
    return [self toContentOffsetForLayout:layout indexPaths:indexPaths
                                placement:placement
                          placementAnchor:kTLPlacementAnchorDefault
                           placementInset:UIEdgeInsetsZero
                                   toSize:self.bounds.size
                           toContentInset:self.contentInset];
}

- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
                    placementAnchor:(CGPoint)placementAnchor
                     placementInset:(UIEdgeInsets)placementInset
                             toSize:(CGSize)toSize
                     toContentInset:(UIEdgeInsets)toContentInset
{
    BOOL defaultPlacementAnchor = CGPointEqualToPoint(placementAnchor, kTLPlacementAnchorDefault);

    CGRect fromFrame = CGRectNull;
    CGRect toFrame = CGRectNull;
    if (indexPaths.count) {
        for (NSIndexPath *indexPath in indexPaths) {
            UICollectionViewLayoutAttributes *fromPose =
                    [layout.currentLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *toPose =
                    [layout.nextLayout layoutAttributesForItemAtIndexPath:indexPath];
            fromFrame = CGRectUnion(fromFrame, fromPose.frame);
            toFrame = CGRectUnion(toFrame, toPose.frame);
        }
    }
    
    CGRect placementFrame = UIEdgeInsetsInsetRect((CGRect){{0, 0}, toSize}, placementInset);
    
    CGPoint contentOffset = self.contentOffset;
    
    // location of the point we're adjusting for, in the coordinate system
    // of the content
    CGPoint sourcePoint;
    
    // location where we want the source point to end up, in the coordinate
    // system of the collection view
    CGPoint destinationPoint;

    if (defaultPlacementAnchor) {
        sourcePoint = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame));
    } else {
        sourcePoint = pointForAnchorPoint(placementAnchor, toFrame);
    }

    switch (placement) {
        case TLTransitionLayoutIndexPathPlacementMinimal:
            if (defaultPlacementAnchor) {
                destinationPoint = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame));
            } else {
                destinationPoint = pointForAnchorPoint(placementAnchor, fromFrame);
            }
            destinationPoint.x -= contentOffset.x;
            destinationPoint.y -= contentOffset.y;
            break;
        case TLTransitionLayoutIndexPathPlacementVisible:
        {
            // calculate the minimal toContentOffset and the resulting
            // frame in collection view space
            CGPoint minimalToContentOffset = [self toContentOffsetForLayout:layout
                                                                 indexPaths:indexPaths
                                                                  placement:TLTransitionLayoutIndexPathPlacementMinimal
                                                            placementAnchor:placementAnchor
                                                             placementInset:placementInset
                                                                     toSize:toSize
                                                             toContentInset:toContentInset];
            CGRect translatedToFrameUnion = toFrame;
            translatedToFrameUnion.origin.x -= minimalToContentOffset.x;
            translatedToFrameUnion.origin.y -= minimalToContentOffset.y;
            // now calculate the minimal offset that maximizes this frame's visibility
            CGPoint maximalIntersectionOffset =
                    minimalOffsetForMaximalIntersection(placementFrame, translatedToFrameUnion);
            minimalToContentOffset.x -= maximalIntersectionOffset.x;
            minimalToContentOffset.y -= maximalIntersectionOffset.y;
            return minimalToContentOffset;
        }
        case TLTransitionLayoutIndexPathPlacementCenter:
            destinationPoint = CGPointMake(CGRectGetMidX(placementFrame), CGRectGetMidY(placementFrame));
            break;
        case TLTransitionLayoutIndexPathPlacementTop:
            if (defaultPlacementAnchor) {
                sourcePoint = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMinY(toFrame));
            }
            destinationPoint = CGPointMake(CGRectGetMidX(placementFrame), CGRectGetMinY(placementFrame));
            break;
        case TLTransitionLayoutIndexPathPlacementLeft:
            if (defaultPlacementAnchor) {
                sourcePoint = CGPointMake(CGRectGetMinX(toFrame), CGRectGetMidY(toFrame));
            }
            destinationPoint = CGPointMake(CGRectGetMinX(placementFrame), CGRectGetMidY(placementFrame));
            break;
        case TLTransitionLayoutIndexPathPlacementBottom:
            if (defaultPlacementAnchor) {
                sourcePoint = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMaxY(toFrame));
            }
            destinationPoint = CGPointMake(CGRectGetMidX(placementFrame), CGRectGetMaxY(placementFrame));
            break;
        case TLTransitionLayoutIndexPathPlacementRight:
            if (defaultPlacementAnchor) {
                sourcePoint = CGPointMake(CGRectGetMaxX(toFrame), CGRectGetMidY(toFrame));
            }
            destinationPoint = CGPointMake(CGRectGetMaxX(placementFrame), CGRectGetMidY(placementFrame));
            break;
        default:
            break;
    }
    
    CGSize contentSize = layout.nextLayout.collectionViewContentSize;
    
    CGPoint offset = CGPointMake(sourcePoint.x - destinationPoint.x, sourcePoint.y - destinationPoint.y);
    
    CGFloat minOffsetX = -toContentInset.left;
    CGFloat minOffsetY = -toContentInset.top;
    
    CGFloat maxOffsetX = toContentInset.right + contentSize.width - placementFrame.size.width;
    CGFloat maxOffsetY = toContentInset.bottom + contentSize.height - placementFrame.size.height;
    maxOffsetX = MAX(minOffsetX, maxOffsetX);
    maxOffsetY = MAX(minOffsetY, maxOffsetY);
    
    offset.x = MAX(minOffsetX, offset.x);
    offset.y = MAX(minOffsetY, offset.y);
    
    offset.x = MIN(maxOffsetX, offset.x);
    offset.y = MIN(maxOffsetY, offset.y);
    
    return offset;
}

- (CGPoint)toContentOffsetForLayout:(UICollectionViewTransitionLayout *)layout
                         indexPaths:(NSArray *)indexPaths
                          placement:(TLTransitionLayoutIndexPathPlacement)placement
                             toSize:(CGSize)toSize
                     toContentInset:(UIEdgeInsets)toContentInset
{
    return [self toContentOffsetForLayout:layout indexPaths:indexPaths
                                placement:placement
                          placementAnchor:kTLPlacementAnchorDefault
                           placementInset:UIEdgeInsetsZero
                                   toSize:toSize
                           toContentInset:toContentInset];
}

- (CGPoint)minimalOffsetForMaximalIntersection
{
    return CGPointZero;
}

CGRect TLTransitionFrame(CGRect fromFrame, CGRect toFrame, CGFloat progress)
{
    CGFloat t = progress;
    CGFloat f = 1 - t;
    CGRect frame;
    frame.origin.x = t * toFrame.origin.x + f * fromFrame.origin.x;
    frame.origin.y = t * toFrame.origin.y + f * fromFrame.origin.y;
    frame.size.width = t * toFrame.size.width + f * fromFrame.size.width;
    frame.size.height = t * toFrame.size.height + f * fromFrame.size.height;
    return frame;
}

CGPoint TLTransitionPoint(CGPoint fromPoint, CGPoint toPoint, CGFloat progress)
{
    CGFloat t = progress;
    CGFloat f = 1 - t;
    CGPoint point;
    point.x = t * toPoint.x + f * fromPoint.x;
    point.y = t * toPoint.y + f * fromPoint.y;
    return point;
}

CGSize TLTransitionSize(CGSize fromSize, CGSize toSize, CGFloat progress)
{
    CGFloat t = progress;
    CGFloat f = 1 - t;
    CGSize size;
    size.width = t * toSize.width + f * fromSize.width;
    size.height = t * toSize.height + f * fromSize.height;
    return size;
}

CGFloat TLTransitionFloat(CGFloat fromFloat, CGFloat toFloat, CGFloat progress)
{
    CGFloat t = progress;
    CGFloat f = 1 - t;
    return t * toFloat + f * fromFloat;
}

UIEdgeInsets TLTransitionInset(UIEdgeInsets fromInset, UIEdgeInsets toInset, CGFloat progress)
{
    CGFloat top = TLTransitionFloat(fromInset.top, toInset.top, progress);
    CGFloat left = TLTransitionFloat(fromInset.left, toInset.left, progress);
    CGFloat bottom = TLTransitionFloat(fromInset.bottom, toInset.bottom, progress);
    CGFloat right = TLTransitionFloat(fromInset.right, toInset.right, progress);
    return UIEdgeInsetsMake(top, left, bottom, right);
}

CGFloat TLConvertTimespace(CGFloat time, CGFloat startTime, CGFloat endTime)
{
    // sanitize input
    time = MAX(0, MIN(1, time));
    startTime = MAX(0, MIN(1, startTime));
    endTime = MAX(0, MIN(1, endTime));
    if (endTime <= startTime) {
        return 1;
    }
    if (time <= startTime) {
        return 0;
    }
    if (time >= endTime) {
        return 1;
    }
    // calculate time in the converted timespace
    return (time - startTime) / (endTime - startTime);
}

extern CGPoint TLRelativePointInRect(CGPoint point, CGRect rect)
{
    CGPoint origin = rect.origin;
    CGPoint relativePoint = CGPointMake(point.x - origin.x, point.y - origin.y);
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    relativePoint.x = width == 0 ? 0 : relativePoint.x / width;
    relativePoint.y = height == 0 ? 0 : relativePoint.y / height;
    return relativePoint;
}

CGPoint addPoints(CGPoint point, CGPoint otherPoint)
{
    return CGPointMake(point.x + otherPoint.x, point.y + otherPoint.y);
}

CGPoint dividePoint(CGPoint point, CGFloat divisor)
{
    if (divisor <= 0) {
        divisor = 1;
    }
    return CGPointMake(point.x  / divisor, point.y / divisor);
}

CGAffineTransform translationToCollectionViewSpace(CGPoint contentOffset)
{
    return CGAffineTransformMakeTranslation(- contentOffset.x, - contentOffset.y);
}

CGPoint pointForAnchorPoint(CGPoint anchorPoint, CGRect frame)
{
    CGFloat pointX = (1.f - anchorPoint.x) * CGRectGetMinX(frame) + anchorPoint.x * CGRectGetMaxX(frame);
    CGFloat pointY = (1.f - anchorPoint.y) * CGRectGetMinY(frame) + anchorPoint.y * CGRectGetMaxY(frame);
    return CGPointMake(pointX, pointY);
}

CGPoint minimalOffsetForMaximalIntersection(CGRect parentFrame, CGRect childFrame)
{
    CGFloat topSpace = CGRectGetMinY(childFrame) - CGRectGetMinY(parentFrame);
    CGFloat leftSpace = CGRectGetMinX(childFrame) - CGRectGetMinX(parentFrame);
    CGFloat bottomSpace = CGRectGetMaxY(parentFrame) - CGRectGetMaxY(childFrame);
    CGFloat rightSpace = CGRectGetMaxX(parentFrame) - CGRectGetMaxX(childFrame);
    return CGPointMake(linearOffset(leftSpace, rightSpace), linearOffset(topSpace, bottomSpace));
}

CGFloat linearOffset(CGFloat spaceBeforeChild, CGFloat spaceAfterChild)
{
    // if both before and after space have the same sign, then there is no offset.
    // If they're both negative, an offset will not improve anything. If they are
    // both positive, no offset is needed.
    if (spaceBeforeChild * spaceAfterChild >= 0) {
        return 0;
    }
    if (spaceBeforeChild < 0) {
        return MIN(spaceAfterChild, -spaceBeforeChild);
    } else {
        return MAX(spaceAfterChild, -spaceBeforeChild);
    }
}

@end

#pragma mark - TLCancelLayout implementation

@interface TLCancelLayout ()
@property (copy, nonatomic) NSArray *poses;
@property (copy, nonatomic) NSDictionary *posesByIndexPath;
@property (nonatomic) CGSize contentSize;
@end

@implementation TLCancelLayout

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout
{
    if (self = [super init]) {
        CGRect rect = (CGRect){{0, 0}, [layout collectionViewContentSize]};
        _poses = [layout layoutAttributesForElementsInRect:rect];
        _posesByIndexPath = [TLCancelLayout posesByIndexPathForPoses:_poses];
        _contentSize = [layout collectionViewContentSize];
        _contentOffset = layout.collectionView.contentOffset;
    }
    return self;
}

+ (NSDictionary *)posesByIndexPathForPoses:(NSArray *)poses
{
    NSMutableDictionary *posesByIndexPath = [NSMutableDictionary dictionaryWithCapacity:[poses count]];
    for (UICollectionViewLayoutAttributes *pose in poses) {
        posesByIndexPath[pose.indexPath] = pose;
    }
    return posesByIndexPath;
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *poses = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *pose in self.poses) {
        if (CGRectIntersectsRect(rect, pose.frame)) {
            [poses addObject:pose];
        }
    }
    return poses;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.posesByIndexPath[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end

