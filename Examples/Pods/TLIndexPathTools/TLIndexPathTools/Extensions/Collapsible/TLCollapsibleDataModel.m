//
//  TLCollapsibleDataModel.m
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

#import "TLCollapsibleDataModel.h"
#import "TLIndexPathSectionInfo.h"

@implementation TLCollapsibleDataModel

#pragma mark - Initialization

- (id)initWithBackingDataModel:(TLIndexPathDataModel *)backingDataModel collapsedSectionNames:(NSSet *)collapsedSectionNames
{
    NSSet *expandedSectionNames = [TLCollapsibleDataModel sectionNamesForDataModel:backingDataModel notInSet:collapsedSectionNames];
    return [self initWithBackingDataModel:backingDataModel expandedSectionNames:expandedSectionNames collapsedSectionNames:collapsedSectionNames];
}

- (id)initWithBackingDataModel:(TLIndexPathDataModel *)backingDataModel expandedSectionNames:(NSSet *)expandedSectionNames
{
    NSSet *collapsedSectionNames = [TLCollapsibleDataModel sectionNamesForDataModel:backingDataModel notInSet:expandedSectionNames];
    return [self initWithBackingDataModel:backingDataModel expandedSectionNames:expandedSectionNames collapsedSectionNames:collapsedSectionNames];
}

- (id)initWithBackingDataModel:(TLIndexPathDataModel *)backingDataModel expandedSectionNames:(NSSet *)expandedSectionNames collapsedSectionNames:(NSSet *)collapsedSectionNames
{
    NSMutableArray *sectionInfos = [NSMutableArray arrayWithCapacity:backingDataModel.numberOfSections];
    for (id<NSFetchedResultsSectionInfo>backingSectionInfo in backingDataModel.sections) {
        if ([collapsedSectionNames containsObject:backingSectionInfo.name]) {
            TLIndexPathSectionInfo *sectionInfo = [[TLIndexPathSectionInfo alloc] initWithItems:@[] name:backingSectionInfo.name indexTitle:backingSectionInfo.indexTitle];
            [sectionInfos addObject:sectionInfo];
        } else {
            [sectionInfos addObject:backingSectionInfo];
        }
    }
    
    if (self = [super initWithSectionInfos:sectionInfos identifierKeyPath:backingDataModel.identifierKeyPath]) {
        _collapsedSectionNames = collapsedSectionNames;
        _expandedSectionNames = expandedSectionNames;
        _backingDataModel = backingDataModel;
    }
    
    return self;
}

+ (NSSet *)sectionNamesForDataModel:(TLIndexPathDataModel *)dataModel notInSet:(NSSet *)sectionNames
{
    NSMutableSet *otherSectionNames = [NSMutableSet set];
    for (NSString *sectionName in dataModel.sectionNames) {
        if (![sectionNames containsObject:sectionName]) {
            [otherSectionNames addObject:sectionName];
        }
    }
    return otherSectionNames;
}

#pragma mark - Collapsed state information

- (BOOL)isSectionCollapsed:(NSInteger)section
{
    NSString *sectionName = [self sectionNameForSection:section];
    BOOL isCollapsed = [self.collapsedSectionNames containsObject:sectionName];
    return isCollapsed;
}

@end
