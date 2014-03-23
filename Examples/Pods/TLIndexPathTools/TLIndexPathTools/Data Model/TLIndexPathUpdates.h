//
//  TLIndexPathUpdates.h
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

#import <UIKit/UIKit.h>
#import "TLIndexPathDataModel.h"

/**
 Takes two versions of a data model and computes the changes, i.e. the inserts,
 moves, deletes and modifications. A variety of `performBatchUpdatesOn*` methods
 are provided for performing batch updates on the table or collection view.
 */

@interface TLIndexPathUpdates : NSObject
@property (strong, nonatomic, readonly) TLIndexPathDataModel *oldDataModel;
@property (strong, nonatomic, readonly) TLIndexPathDataModel *updatedDataModel;
@property (strong, nonatomic, readonly) NSArray *insertedSectionNames;
@property (strong, nonatomic, readonly) NSArray *deletedSectionNames;
@property (strong, nonatomic, readonly) NSArray *movedSectionNames;
@property (strong, nonatomic, readonly) NSArray *insertedItems;
@property (strong, nonatomic, readonly) NSArray *deletedItems;
@property (strong, nonatomic, readonly) NSArray *movedItems;
@property (strong, nonatomic, readonly) NSArray *modifiedItems;
- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation;
- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation completion:(void(^)(BOOL finished))completion;
- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView;
- (void)performBatchUpdatesOnCollectionView:(UICollectionView *)collectionView completion:(void(^)(BOOL finished))completion;
- (id)initWithOldDataModel:(TLIndexPathDataModel *)oldDataModel updatedDataModel:(TLIndexPathDataModel *)updatedDataModel;
@end
