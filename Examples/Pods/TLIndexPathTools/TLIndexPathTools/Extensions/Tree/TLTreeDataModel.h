//
//  TLTreeDataModel.h
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

/**
 A data model representing a heirarchy of `TLIndexPathTreeItem` nodes in a given
 collapsed stated. This class must be initialized by using one of the two initializers
 defined here, providing either an array of top level `TLIndexPathTreeItem` nodes
 or an array of `TLIndexPathSectionInfos` containing top level nodes (particularly
 if empty sections are needed) and the current set of collapsed node identifiers.
 
 These initializers flatten the heirarchy into the array of items to be displayed
 in the table. This flattened data is passed up to the `TLIndexPathDataModel`
 initializer and, thus, the basic data model APIs reflect only the flattened data
 to be displayed. The full data heirarchy is retained in the `treeItems`
 and `treeItemSections` properties.
 
 This data model can be plugged into a `TLTableViewController`, but
 one should normally use `TLTreeTableViewController` because it contains the
 additional logic to automatically update the data model as rows are expanded
 and collapsed. It also provides a mechanism to lazy load nodes.
 */

#import "TLIndexPathDataModel.h"

@interface TLTreeDataModel : TLIndexPathDataModel
@property (copy, nonatomic, readonly) NSArray *collapsedNodeIdentifiers;
@property (copy, nonatomic, readonly) NSArray *treeItems;
@property (copy, nonatomic, readonly) NSArray *treeItemSections;
- (instancetype)initWithTreeItems:(NSArray *)treeItems collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers;
- (instancetype)initWithTreeItemSections:(NSArray *)treeItemSections collapsedNodeIdentifiers:(NSArray *)collapsedNodeIdentifiers;
@end
