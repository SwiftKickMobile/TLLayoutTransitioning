//
//  TLIndexPathController.m
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

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"
#import "TLIndexPathUpdates.h"

NSString * const TLIndexPathControllerChangedNotification = @"TLIndexPathControllerChangedNotification";
NSString * kTLIndexPathControllerChangedNotification = @"kTLIndexPathControllerChangedNotification";
NSString * kTLIndexPathUpdatesKey = @"kTLIndexPathUpdatesKey";

@interface TLIndexPathController ()
@property (strong, nonatomic) NSFetchedResultsController *backingController;
@property (strong, nonatomic) TLIndexPathDataModel *oldDataModel;
@property (nonatomic) BOOL performingBatchUpdate;
@property (nonatomic) BOOL pendingConvertFetchedObjectsToDataModel;
@end

@implementation TLIndexPathController

- (void)dealloc {
    //the delegate property is an 'assign' property
    //not technically needed because the FRC will dealloc when we do, but it's a good idea.
    self.backingController.delegate = nil;
}

#pragma mark - Creating controllers

- (instancetype)initWithItems:(NSArray *)items
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:items sectionNameKeyPath:nil identifierKeyPath:nil];
    return [self initWithDataModel:dataModel];
}

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel
{
    if (self = [super init]) {
        _dataModel = dataModel;
    }
    return self;
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name
{
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:nil sectionNameKeyPath:sectionNameKeyPath identifierKeyPath:identifierKeyPath];
    if (self = [self initWithDataModel:dataModel]) {
        //initialize the backing controller with nil sectionNameKeyPath because we don't require
        //items to be sorted by section, but NSFetchedResultsController does.
        _backingController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:name];
        _backingController.delegate = self;
    }
    return self;
}

#pragma mark - Configuration information

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest
{
    if (![self.fetchRequest isEqual:fetchRequest]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:self.backingController.managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:self.backingController.cacheName];
        self.backingController.delegate = self;
    }
}

- (NSFetchRequest *)fetchRequest
{
    return self.backingController.fetchRequest;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (![self.managedObjectContext isEqual:managedObjectContext]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:self.backingController.fetchRequest
                                  managedObjectContext:managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:self.backingController.cacheName];
        self.backingController.delegate = self;
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.backingController.managedObjectContext;
}

- (void)setCacheName:(NSString *)cacheName
{
    if (![self.cacheName isEqual:cacheName]) {
        self.backingController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:self.backingController.fetchRequest
                                  managedObjectContext:self.backingController.managedObjectContext
                                  sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                  cacheName:cacheName];
        self.backingController.delegate = self;
    }
}

- (NSString *)cacheName
{
    return self.backingController.cacheName;
}

+ (void)deleteCacheWithName:(NSString *)name
{
    [NSFetchedResultsController deleteCacheWithName:name];
}

- (void)setIgnoreFetchedResultsChanges:(BOOL)ignoreFetchedResultsChanges
{
    if (_ignoreFetchedResultsChanges != ignoreFetchedResultsChanges) {
        _ignoreFetchedResultsChanges = ignoreFetchedResultsChanges;
        //if fetch was ever performed, automatically re-perform fetch when
        //ignoring is disabled.
        if (NO == ignoreFetchedResultsChanges && self.isFetched) {
            self.dataModel = [self convertFetchedObjectsToDataModel];
        }
    }
}

#pragma mark - Accessing and updating

- (NSArray *)items
{
    return self.dataModel.items;
}

- (void)setItems:(NSArray *)items
{
    if (items ==  nil) {
        self.dataModel = nil;
    }
    
    else if (![self.items isEqualToArray:items]) {
        id last = [items lastObject];
        TLIndexPathDataModel *dataModel;
        if ([last isKindOfClass:[TLIndexPathItem class]]) {
            dataModel = [[TLIndexPathDataModel alloc] initWithItems:items];
        } else {
            dataModel = [[TLIndexPathDataModel alloc] initWithItems:items
                                              sectionNameKeyPath:self.dataModel.sectionNameKeyPath
                                               identifierKeyPath:self.dataModel.identifierKeyPath];
        }
        self.dataModel = dataModel;
    }
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel
{
    if (![_dataModel isEqual:dataModel]) {
        
        //any explicitly set data model overrides pending conversion of fetched objects
        self.pendingConvertFetchedObjectsToDataModel = NO;
        
        //data model may get set multiple times during batch udpates,
        //so make sure we remember the initial old data model (which will
        //get cleared in `performUpdates` when the batch updates complete).
        if (!self.oldDataModel) {
            self.oldDataModel = _dataModel;
        }
        
        _dataModel = dataModel;
        
        //perform udpates immediately unless we're in batch update mode
        if (!self.performingBatchUpdate) {
            [self dequeuePendingUpdates];
        }
    }
}

- (void)dequeuePendingUpdates
{
    if ([self.delegate respondsToSelector:@selector(controller:willUpdateDataModel:withDataModel:)]) {
        TLIndexPathDataModel *dataModel = [self.delegate controller:self willUpdateDataModel:self.oldDataModel withDataModel:self.dataModel];
        if (dataModel) {
            //bypass the property setter here because we don't need any of that logic
            _dataModel = dataModel;
        }
    }
    TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:self.oldDataModel updatedDataModel:self.dataModel];
    if ([self.delegate respondsToSelector:@selector(controller:didUpdateDataModel:)] && !self.ignoreDataModelChanges) {
        [self.delegate controller:self didUpdateDataModel:updates];
    }
    NSDictionary *info = @{kTLIndexPathUpdatesKey : updates};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLIndexPathControllerChangedNotification object:self userInfo:info];
    self.oldDataModel = nil;
}

#pragma mark - Batch updates

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion
{
    self.performingBatchUpdate = YES;
    
    if (updates) {
        updates();
    }
    
    if (self.pendingConvertFetchedObjectsToDataModel) {
        self.dataModel = [self convertFetchedObjectsToDataModel];
    }
    
    [self dequeuePendingUpdates];
    
    self.performingBatchUpdate = NO;
    
    if (completion) {
        completion(YES);
    }
}

#pragma mark - Core Data Integration

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL result = [self.backingController performFetch:error];
    if (self.performingBatchUpdate) {
        self.pendingConvertFetchedObjectsToDataModel = YES;
    } else {
        self.dataModel = [self convertFetchedObjectsToDataModel];
    }
    self.isFetched = YES;
    return result;
}

- (NSArray *)coreDataFetchedObjects
{
    return self.backingController.fetchedObjects;
}

- (void)setInMemoryPredicate:(NSPredicate *)inMemoryPredicate
{
    if (_inMemoryPredicate != inMemoryPredicate) {
        _inMemoryPredicate = inMemoryPredicate;
        if (self.performingBatchUpdate) {
            self.pendingConvertFetchedObjectsToDataModel = YES;
        } else {
            self.dataModel = [self convertFetchedObjectsToDataModel];
        }
    }
}

- (void)setInMemorySortDescriptors:(NSArray *)inMemorySortDescriptors
{
    if (![_inMemorySortDescriptors isEqualToArray:inMemorySortDescriptors]) {
        _inMemorySortDescriptors = inMemorySortDescriptors;
        if (self.performingBatchUpdate) {
            self.pendingConvertFetchedObjectsToDataModel = YES;
        } else {
            self.dataModel = [self convertFetchedObjectsToDataModel];
        }
    }
}

- (TLIndexPathDataModel *)convertFetchedObjectsToDataModel {
    NSArray *filteredItems = self.inMemoryPredicate ? [self.coreDataFetchedObjects filteredArrayUsingPredicate:self.inMemoryPredicate] : self.coreDataFetchedObjects;
    NSArray *sortedFilteredItems = self.inMemorySortDescriptors ? [filteredItems sortedArrayUsingDescriptors:self.inMemorySortDescriptors] : filteredItems;
    return [[TLIndexPathDataModel alloc] initWithItems:sortedFilteredItems
                                    sectionNameKeyPath:self.backingController.sectionNameKeyPath
                                     identifierKeyPath:self.dataModel.identifierKeyPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.ignoreFetchedResultsChanges) {
            self.dataModel = [self convertFetchedObjectsToDataModel];
        }
    });
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
