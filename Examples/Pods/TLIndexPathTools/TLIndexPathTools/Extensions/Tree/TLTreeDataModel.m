//
//  TLTreeDataModel.m
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

#import "TLTreeDataModel.h"
#import "TLIndexPathTreeItem.h"
#import "TLIndexPathSectionInfo.h"

@implementation TLTreeDataModel

- (instancetype)initWithTreeItems:(NSArray *)treeItems collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers
{
    // let `TLIndexPathDataModel` organize the tree items into sections and then
    // use the section-based inititializer
    TLIndexPathDataModel *tempDataModel = [[TLIndexPathDataModel alloc] initWithItems:treeItems];
    return [self initWithTreeItemSections:tempDataModel.sections collapsedNodeIdentifiers:collapsedNodeIdentifiers];
}

- (instancetype)initWithTreeItemSections:(NSArray *)treeItemSections collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers
{
    NSMutableArray *treeItems = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[treeItemSections count]];
    for (id<NSFetchedResultsSectionInfo>treeItemSection in treeItemSections) {
        [treeItems addObjectsFromArray:[treeItemSection objects]];
        NSMutableArray *items = [NSMutableArray array];
        for (TLIndexPathTreeItem *item in [treeItemSection objects]) {
            [self flattenTreeItem:item intoArray:items withCollapsedNodeIdentifiers:collapsedNodeIdentifiers];
        }
        TLIndexPathSectionInfo *section = [[TLIndexPathSectionInfo alloc] initWithItems:items
                                                                                   name:treeItemSection.name
                                                                             indexTitle:treeItemSection.indexTitle];
        [sections addObject:section];
    }
    if (self = [super initWithSectionInfos:sections identifierKeyPath:nil]) {
        _treeItems = treeItems;
        _treeItemSections = treeItemSections;
        _collapsedNodeIdentifiers = collapsedNodeIdentifiers;
    }
    return self;
}

- (void)flattenTreeItem:(TLIndexPathTreeItem *)item intoArray:(NSMutableArray *)items withCollapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers
{
    if (item) {
        [items addObject:item];
        if (![collapsedNodeIdentifiers containsObject:item.identifier]) {
            for (TLIndexPathTreeItem *childItem in item.childItems) {
                [self flattenTreeItem:childItem intoArray:items withCollapsedNodeIdentifiers:collapsedNodeIdentifiers];
            }
        }
    }
}

@end
