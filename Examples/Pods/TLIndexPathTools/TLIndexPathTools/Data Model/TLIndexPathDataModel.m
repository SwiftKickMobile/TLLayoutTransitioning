//
//  TLIndexPathDataModel.m
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

#import "TLIndexPathDataModel.h"
#import <CoreData/CoreData.h>
#import "TLIndexPathItem.h"
#import "TLIndexPathSectionInfo.h"

const NSString *TLIndexPathDataModelNilSectionName = @"__TLIndexPathDataModelNilSectionName__";

@interface TLIndexPathDataModel ()
@property (strong, nonatomic) NSString *(^sectionNameBlock)(id item);
@property (strong, nonatomic) id(^identifierBlock)(id item);
@property (strong, nonatomic) NSMutableDictionary *itemsByIdentifier;
@property (strong, nonatomic) NSMutableDictionary *sectionInfosBySectionName;
@property (strong, nonatomic) NSMutableDictionary *identifiersByIndexPath;
@property (strong, nonatomic) NSMutableDictionary *indexPathsByIdentifier;
@end

@implementation TLIndexPathDataModel

@synthesize identifierKeyPath = _identifierKeyPath;
@synthesize sectionNameKeyPath = _sectionNameKeyPath;
@synthesize numberOfSections = _sectionCount;
@synthesize itemsByIdentifier = _itemsByIdentifier;
@synthesize identifiersByIndexPath = _identifiersByIndexPath;
@synthesize indexPathsByIdentifier = _indexPathsByIdentifier;
@synthesize items = _items;
@synthesize indexPaths = _indexPaths;
@synthesize sectionNames = _sectionNames;
@synthesize sections = _sections;

#pragma mark - Creating data models

- (id)init
{
    return [self initWithItems:nil sectionNameKeyPath:nil identifierKeyPath:nil];
}

- (id)initWithItems:(NSArray *)items
{
    return [self initWithItems:items sectionNameKeyPath:nil identifierKeyPath:nil];
}

- (id)initWithItems:(NSArray *)items sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath
{
    
    NSString *(^sectionNameBlock)(id item);
    if (sectionNameKeyPath) {
       sectionNameBlock = ^NSString *(id item) {
            @try {
                return sectionNameKeyPath ? [item valueForKeyPath:sectionNameKeyPath] : nil;
            }
            @catch (NSException *exception) {
            }
            return nil;
        };
    }
    id(^identifierBlock)(id item);
    if (identifierKeyPath) {
        identifierBlock = ^id(id item) {
            @try {
                return identifierKeyPath ? [item valueForKeyPath:identifierKeyPath] : nil;
            }
            @catch (NSException *exception) {
            }
            return nil;
        };
    }
    
    if (self = [self initWithItems:items sectionNameBlock:sectionNameBlock identifierBlock:identifierBlock]) {
        _identifierKeyPath = identifierKeyPath;
        _sectionNameKeyPath = sectionNameKeyPath;
    }
    return self;
}

- (id)initWithItems:(NSArray *)items sectionNameBlock:(NSString *(^)(id))sectionNameBlock identifierBlock:(id (^)(id))identifierBlock
{
    NSMutableDictionary *itemsByIdentifier = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *itemsBySectionName = [[NSMutableDictionary alloc] init];
    NSMutableArray *sectionNames = [NSMutableArray array];
    
    //group items by section name and remove any duplicate identifiers
    for (id item in items) {
        id identifier = [TLIndexPathDataModel identifierForItem:item identifierBlock:identifierBlock];
        if (!identifier || [itemsByIdentifier objectForKey:identifier]) continue;
        NSString *sectionName = [TLIndexPathDataModel sectionNameForItem:item sectionNameBlock:sectionNameBlock];
        NSMutableArray *sectionItems = [itemsBySectionName objectForKey:sectionName];
        if (!sectionItems) {
            sectionItems = [NSMutableArray array];
            [itemsBySectionName setObject:sectionItems forKey:sectionName];
            [sectionNames addObject:sectionName];
        }
        [sectionItems addObject:item];
        [itemsByIdentifier setObject:item forKey:identifier];
    }
    
    //create section infos
    NSMutableArray *sectionInfos = [NSMutableArray arrayWithCapacity:sectionNames.count];
    for (NSString *sectionName in sectionNames) {
        NSArray *sectionItems = [itemsBySectionName objectForKey:sectionName];
        TLIndexPathSectionInfo *sectionInfo = [[TLIndexPathSectionInfo alloc] initWithItems:sectionItems name:sectionName indexTitle:sectionName];
        [sectionInfos addObject:sectionInfo];
    }
    
    if (self = [self initWithSectionInfos:sectionInfos sectionNameBlock:sectionNameBlock identifierBlock:identifierBlock]) {
//        _itemsByIdentifier = itemsByIdentifier;//TODO
//        _sectionNames = sectionNames;//TODO
    }
    return self;
}

- (id)initWithSectionInfos:(NSArray *)sectionInfos identifierKeyPath:(NSString *)identifierKeyPath
{
    id(^identifierBlock)(id item) = ^id(id item) {
        @try {
            return identifierKeyPath ? [item valueForKeyPath:identifierKeyPath] : nil;
        }
        @catch (NSException *exception) {
        }
        return nil;
    };
    
    if (self = [self initWithSectionInfos:sectionInfos sectionNameBlock:nil identifierBlock:identifierBlock]) {
        _identifierKeyPath = identifierKeyPath;
    }
    return self;
}

- (id)initWithSectionInfos:(NSArray *)sectionInfos sectionNameBlock:(NSString *(^)(id))sectionNameBlock identifierBlock:(id (^)(id))identifierBlock
{
    //if there are no sections, insert an empty section to keep UICollectionView
    //happy. If we don't do this, UICollectionView will crash on the first
    //update because it internally thinks there is 1 section when the
    //UICollectionView controller reports zero sections.
    if (sectionInfos.count == 0) {
        TLIndexPathSectionInfo *sectionInfo = [[TLIndexPathSectionInfo alloc]
                                               initWithItems:nil
                                               name:[TLIndexPathDataModelNilSectionName copy]
                                               indexTitle:nil];
        sectionInfos = @[sectionInfo];
    }
    
    if (self = [super init]) {
        
        _identifierBlock = identifierBlock;
        _sectionNameBlock = sectionNameBlock;
        
        NSMutableArray *identifiedItems = [[NSMutableArray alloc] init];
        NSMutableArray *sectionNames = [[NSMutableArray alloc] init];
        
        _itemsByIdentifier = [[NSMutableDictionary alloc] init];
        _identifiersByIndexPath = [[NSMutableDictionary alloc] init];
        _indexPathsByIdentifier = [[NSMutableDictionary alloc] init];
        _sectionInfosBySectionName = [[NSMutableDictionary alloc] init];
        _sectionNames = sectionNames;
        _sections = sectionInfos;
        _items = identifiedItems;
        
        NSInteger section = 0;
        for (id<NSFetchedResultsSectionInfo>sectionInfo in sectionInfos) {
            
            NSInteger row = 0;
            
            for (id item in sectionInfo.objects) {
                
                id identifier = [self identifierForItem:item];
                //we can't remove duplicate items because section infos are
                //immutable. So the strategy will be to make duplicate items behave
                //just like any other item with the exception that they cannot be
                //looked up by identifier. TODO this needs to be tested.
                if (identifier && ![_itemsByIdentifier objectForKey:identifier]) {
                    [identifiedItems addObject:item];
                    [_itemsByIdentifier setObject:item forKey:identifier];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    [_identifiersByIndexPath setObject:identifier forKey:[self keyForIndexPath:indexPath]];
                    [_indexPathsByIdentifier setObject:indexPath forKey:identifier];
                };
                
                row++;
            }
            
            [_sectionInfosBySectionName setObject:sectionInfo forKey:sectionInfo.name];
            [sectionNames addObject:sectionInfo.name];
            
            section++;
        }
        
        _sectionCount = sectionInfos.count;
    }
    
    return self;
}

#pragma mark - Data model content

- (NSArray *)indexPaths
{
    //TODO maybe sort this?
    return [self.indexPathsByIdentifier allValues];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [self sectionInfoForSection:section];
    return sectionInfo ? [sectionInfo objects].count : NSNotFound;
}

- (NSString *)sectionNameForSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [self sectionInfoForSection:section];
    return [sectionInfo name];
}

- (NSInteger)sectionForSectionName:(NSString *)sectionName
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [self.sectionInfosBySectionName objectForKey:sectionName];
    return sectionInfo ? [self.sections indexOfObject:sectionInfo] : NSNotFound;
}

- (NSString *)sectionTitleForSection:(NSInteger)section
{
    NSString *sectionName = [self sectionNameForSection:section];
    if ([TLIndexPathDataModelNilSectionName isEqualToString:sectionName]) {
        return nil;
    }
    return sectionName;
}

- (TLIndexPathSectionInfo *)sectionInfoForSection:(NSInteger)section
{
    if (self.sections.count <= section) {
        return nil;
    }
    return self.sections[section];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    
    id identifier = [self identifierAtIndexPath:indexPath];
    id item = [self.itemsByIdentifier objectForKey:identifier];
    return item;
}

- (id)identifierAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.identifiersByIndexPath objectForKey:[self keyForIndexPath:indexPath]];
}

- (BOOL)containsItem:(id)item
{
    return [self indexPathForItem:item] != nil;
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    id identifier = [self identifierForItem:item];
    NSIndexPath *indexPath = [self.indexPathsByIdentifier objectForKey:identifier];
    return indexPath;
}

- (NSIndexPath *)indexPathForIdentifier:(id)identifier
{
    id item = [self itemForIdentifier:identifier];
    return [self indexPathForItem:item];
}

- (id)identifierForItem:(id)item
{
    return [[self class] identifierForItem:item identifierBlock:self.identifierBlock];
}

+ (id)identifierForItem:(id)item identifierBlock:(id (^)(id))identifierBlock
{
    id identifier;
    if (identifierBlock) {
        @try {
            identifier = identifierBlock(item);
        }
        @catch (NSException *exception) {
        }
    }
    if (!identifier && [item isKindOfClass:[TLIndexPathItem class]]) {
        identifier = ((TLIndexPathItem *)item).identifier;
    }
    if (!identifier && [item isKindOfClass:[NSManagedObject class]]) {
        identifier = ((NSManagedObject *)item).objectID;
    }
    if (!identifier && [item conformsToProtocol:@protocol(NSCopying)]) {
        identifier = item;
    }
    if (!identifier) {
        identifier = [NSString stringWithFormat:@"%p", item];
    }
    return identifier;
}

- (id)itemForIdentifier:(id)identifier
{
    return [self.itemsByIdentifier objectForKey:identifier];
}

- (id)currentVersionOfItem:(id)anotherVersionOfItem
{
    id identifier = [self identifierForItem:anotherVersionOfItem];
    id item = [self itemForIdentifier:identifier];
    return item;
}

- (NSString *)sectionNameForItem:(id)item
{
    return [[self class] sectionNameForItem:item sectionNameBlock:self.sectionNameBlock];
}

+ (NSString *)sectionNameForItem:(id)item sectionNameBlock:(NSString *(^)(id))sectionNameBlock
{
    NSString *sectionName;
    if (sectionNameBlock) {
        @try {
            sectionName = sectionNameBlock(item);
        } @catch(NSException *e) {
        }
    }
    if (!sectionName && [item isKindOfClass:[TLIndexPathItem class]]) {
        sectionName = ((TLIndexPathItem *)item).sectionName;
    }
    if (!sectionName) {
        sectionName = [TLIndexPathDataModelNilSectionName copy];
    }
    return sectionName;
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

@end
