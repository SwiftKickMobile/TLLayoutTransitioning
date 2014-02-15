//
//  TLIndexPathDataModel.h
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

 `TLIndexPathDataModel` is an immutable object you use in your view controller to hold
 your data items instead of an array. Creating a data model is as easy as passing
 an array of items (of any type) to the initializer. Or if the data needs to be
 organized into sections, there are two additional initializers, one for implicitly
 defined sections using `sectionNameKeyPath` and another for an explicitly defined
 array of `TLIndexPathSectionInfo` objects. A multitude of APIs are provided for
 accessing the data and translating between index paths and data items.
 
 This class can be used on it's own to help fulfill the table or collection view
 data source and delegate methods. For example, the prototypically implementation
 of `numberOfRowsInSection` is:
 
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return [self.dataModel numberOfRowsInSection:section];
    }
 
 But the real power of TLIndexPathTools lies in use of the companion class
 `TLIndexPathUpdates` to perform animated batch udpates when items are inserted,
 moved or deleted from the data model. To modify the data model, one would typically
 either extract items from the current data model into an `NSMUtableArray`, make changes,
 and then instantiate a new data model with the updated items:
 
    TLIndexPathDataModel *oldDataModel = self.dataModel;
    NSMutableArray *items = [NSMutableArray arrayWithArray:oldDataModel.items];
    ... //make changes to items
    self.dataModel = [TLIndexPathDataModel alloc] initWithItems:items];

    //batch updates
    TLIndexPathUpdates *updates = [TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:self.dataModel];
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];
 
 Another common pattern is to write a factory method for the data model that recreates
 the data model from scratch based current state of the view controller:
 
    TLIndexPathDataModel *oldDataModel = self.dataModel;
    self.dataModel = [self newDataModel];

    //batch updates
    TLIndexPathUpdates *updates = [TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:self.dataModel];
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];

 But the recommended approach is to use `TLIndexPathController` because it works interchangeably
 with Core Data `NSFetchRequests` or plain arrays of arbitrary data. Thus, it provides a
 unified programming model for building tables and collection views. The typical way to use
 `TLIndexPathController` is:
 
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.indexPathController.items];
    ... //make changes to items
    self.indexPathController.items = items;
 
 where the `items` property is just a shortcut for setting the `dataModel` property.
 
 When the controller's data model gets updated, the it calls its delegate methods,
 the primiry one being `didUpdateDataModel`. The typical implementation would simply
 perform the batch updates:
 
    - (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
    {
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];
    }

 When working with Core Data, the main differences is that you'd initialize the
 `TLIndexPathController` with an `NSFetchRequest` and then the data model get
 generated/updated internally as the fetch results change.
 
 Another advantage in using `TLIndexPathController` is that you can define base table
 and collection view controller classes and use them everywhere (i.e. with or without
 Core Data). TLIndexPathTools provides two such implementations: `TLTableViewController`
 and `TLCollectionViewController`. Both classes provide default implementations of
 the essential data source and delegate methods to get you up-and-running quickly.
 `TLTableViewController` also provides a default implementation of `heightForRowAtIndexPath`
 that can handle custom cell heights (static heights defined in Interface Builder or dynamic
 heights defined by implementing the `TLDynamicSizeView` protocol in a custom cell class).
 
 ###Item Identification
 
 `TLIndexPathDataModel` needs to be able to identify items in order to keep an internal
 mapping between items and index paths and to track items across versions of the data
 model. It does not assume that the item itself is a valid identifier (for example,
 if the item doesn not implement `NSCopying`, it cannot be used as a dictionary key).
 So the following set of rules are used to locate a valid identifier. Each rule
 is tried in turn until a non-nil value is found:
 
 1. If `identifierKeyPath` is specified (through an appropriate initializer),
    the data model attempts to use the item's value for this key path. If the key
    path is invalid for the given item, the next rule is tried.
 2. If the item is an instance of `TLIndexPathItem`, the value of the `identifier`
    property is tried.
 3. If the item is an instance of `NSManagedObject`, the `objectID` property is used.
 4. If the item conforms to `NSCopying`, the item itself is used.
 5. If all else fails, the item's memory address is returned as a string.

 ###Section Name Identifcation
 
 `TLIndexPathDataModel` identifies sections by their name, which is defined according
 to the following rules.
 
 1. If `sectionNameKeyPath` is specified (through the appropriate initializer),
    the data model attempts to use the item's value for this key path. If the key
    path is invalid for the given item, the next rule is tried.
 2. If the item is an instance of `TLIndexPathItem`, the value of the `sectionName`
    property is tried.
 3. The value TLIndexPathDataModelNilSectionName is used.
 
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

extern NSString * TLIndexPathDataModelNilSectionName;

@interface TLIndexPathDataModel : NSObject

#pragma mark - Creating data models
/** @name Creating data models */

/**
 The basic initializer.
 
 This initializer can only organize data into a single section and use the default
 item identification rules. Use one of the other initializers if you need multiple
 sections or need to specify an `identifierKeyPath`. An exception to this if your
 items are instance of the `TLIndexPathItem` wrapper class since the data model is
 aware of, and will make use of the buit in `identifier` and `sectionName` properties.
 
 @param items  the itmes that make up the data model
 */
- (id)initWithItems:(NSArray *)items;

/**
 Use this initializer to organize sections by the item `sectionNameKeyPath` property
 or to identify items by their `identifierKeyPath` property.
 
 @param items  the itmes that make up the data model
 @param sectionNameKeyPath  the item key path to use for orgnizing data into sections.
        Note that items do not need to be pre-sorted by sectionNameKeyPath. Specifying `nil`
        will result in a single section named `TLIndexPathDataModelNilSectionName`.
 @param identifierKeyPath  the item key path to use for identification. Specifying `nil`
        will result in the default object identification rules being used.
 */
- (id)initWithItems:(NSArray *)items sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath;

/**
 Use this initializer to organize sections and identify items using blocks. This
 can be used, for example, to organize a list of strings into sections based on
 the first letter of the string (similar to the Contacts app).
 
 @param items  the itmes that make up the data model
 @param sectionNameBlock  block that returns the section name for the given item
 Note that items do not need to be pre-sorted. Specifying `nil` will result in a
 single section named `TLIndexPathDataModelNilSectionName`.
 @param identifierBlock  block that returns the identifier for the given item.
 Specifying `nil` will result in the default object identification rules being used.
 */
- (id)initWithItems:(NSArray *)items sectionNameBlock:(NSString *(^)(id item))sectionNameBlock identifierBlock:(id(^)(id item))identifierBlock;

/**
 Use this initializer to explicitly specify sections by providing an array of
 `TLIndexPathSectionInfo` objects. This initializer can be used to generate empty sections
 (by creating an empty `TLIndexPathSectionInfo` object).

 @param sectionInfos  the section info objects that make up the data model
 @param identifierKeyPath  the item key path to use for identification. Specifying `nil`
 will result in the default object identification rules being used.
*/
- (id)initWithSectionInfos:(NSArray *)sectionInfos identifierKeyPath:(NSString *)identifierKeyPath;

#pragma mark - Data model configuration
/** @name Data model configuration */

/**
 The key path used to identify items. Identifier key paths can be used when the item
 itself is not a suitable identifier (see Item Identification). An example is when
 the data model contains raw JSON data (dictionaries). In order to refresh the data,
 a new JSON response will contain new dictionary items. Without an identifier key path,
 it will not be possible to identify items across data models if any of the data has
 changed (due to the way [NSDictionary isEqual] works). However, JSON data items
 typically contain a key field, such as "recordId", that identifies the item. By setting
 the `identifierKeyPath` to this key field, TLIndexPathTools will be able to track
 items across data models.
 */
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;

/**
 The key path used to identify an item's section. If specified in the relevant
 initializer, the data model items will be organized into sections according to
 the value of the their `sectionNameKeyPath`. Unlike `NSFetchedResultsController`,
 items do not need to be presorted by section.
 */
@property (strong, nonatomic, readonly) NSString *sectionNameKeyPath;

#pragma mark - Data model content
/** @name Data model content */

/**
 The title of the data model. Can be used to store a value for the view controller's `title` property.
 This property will be removed in a later version.
 */
@property (strong, nonatomic) NSString *title __attribute__((deprecated));

/**
 The number of sections in the data model.
 */
@property (nonatomic, readonly) NSInteger numberOfSections;

/**
 The array of section names in the data model. If the model has been initialized without
 any explicit sections, this array will contain the single name `TLIndexPathDataModelNilSectionName`.
 Note that section names are unique. See Section Names.
 */
@property (strong, nonatomic, readonly) NSArray *sectionNames;

/**
 The array of `TLIndexPathSectionInfo` objects organizing the data into sections.
 `TLIndexPathSectionInfo` is an implementation of the `NSFetchedResultsSectionInfo` protocol.
 */
@property (strong, nonatomic, readonly) NSArray *sections;

/**
 An array containing all items.
 */
@property (strong, nonatomic, readonly) NSArray *items;

/**
 An array containing all index paths.
 */
@property (strong, nonatomic, readonly) NSArray *indexPaths;

/**
 The number of rows in the specified section. Returns `NSNotFound` for an invalid section.
 
 @param section  the specified section index
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 The unique name for the givne section. Returns `nil` for an invalid section.

 @param section  the specified section index
*/
- (NSString *)sectionNameForSection:(NSInteger)section;

/**
 The section number for the given section name. Returns `NSNotFound` for an invalid section name.
 
 @param sectionName  the specified section name
 */
- (NSInteger)sectionForSectionName:(NSString *)sectionName;

/**
 Currently returns section name.

 @param section  the specified section index
*/
- (NSString *)sectionTitleForSection:(NSInteger)section;

/**
 Returns the `TLIndexPathSectionInfo` object for the given section. Returns nil for an invalid section.

 @param section  the specified section index
*/
- (id<NSFetchedResultsSectionInfo>)sectionInfoForSection:(NSInteger)section;

/**
 Returns the item at the given index path. Returns `nil` for an invalid index path.
 
 @param indexPath  the specified index path
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the item identifier at the given index path. Returns `nil` for an invalid index path.
 
 @param indexPath  the specified index path
 */
- (id)identifierAtIndexPath:(NSIndexPath *)indexPath;

/**
 Retuns YES if the data model contains the given item.
 
 @param item  the specified item
 */
- (BOOL)containsItem:(id)item;

/**
 Returns the index path for the given item. Returns `nil` if the item is not a member of the data model.
 
 @param item  the specified item
 */
- (NSIndexPath *)indexPathForItem:(id)item;

/**
 Returns the index path for the given identifier. Returns `nil` for an invalid identifier.
 
 @param identifier  the specified identifier
 */
- (NSIndexPath *)indexPathForIdentifier:(id)identifier;

/**
 Returns the identifier for the given item. Returns `nil` if the item is not a member of the data model.
 
 @param item  the specified item
 */
- (id)identifierForItem:(id)item;

/**
 Returns the item for the given identifier. Returns `nil` for an invalid identifier.
 
 @param identifier  the specified identifier
 */
- (id)itemForIdentifier:(id)identifier;

/**
 Returns the current version of the given item. This method can be useful in scenarios
 where different versions of the data model contain different instances representing the
 same items. Note that this method is just a shortcur for calling `identifierForItem:` followed
 by `itemForIdentifier:`.
 
 @param anotherVersionOfItem  the specified item from a different version of the data model.
 */
- (id)currentVersionOfItem:(id)anotherVersionOfItem;

@end
