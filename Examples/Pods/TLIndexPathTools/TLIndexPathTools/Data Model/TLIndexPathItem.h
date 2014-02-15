//
//  TLIndexPathItem.h
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
 A data item wrapper class that provides identifier and section name properties.
 TLIndexPathTools knows about and will use these properties automatically as specified
 in the `TLIndexPathDataModel` identifier and section name rules. This means the more
 verbose `[TLIndexPathTools initWithItems:sectionNameKeyPath:identifierKeyPath]`
 initializer is unneccessary. Use the [TLIndexPathTools initWithItems:] initializer.
 
 This class also provides a `cellIdentifier` property. If this property is set,
 `TLTableViewController` and `TLCollectionViewController` automatically use this
 value as the reuse identifier when dequeing cells.
 
 This class can be useful for settings-type views where there are multiple cell
 prototypes, heterogeneous data and sections.
 */

#import <Foundation/Foundation.h>

@interface TLIndexPathItem : NSObject
@property (strong, nonatomic) id identifier;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) id data;

/**
 Returns YES if the item should be considered modified if the data is modified.
 This affects whether or not the corresponding cell is reloaded in a batch update.
 Specifically, if the value is YES, the `hash` and `isEqual` methods take into
 account the value of `data`. The default value is NO.
 */
@property (nonatomic) BOOL shouldCompareData;

- (id)initWithIdentifier:(id)identifier sectionName:(NSString *)sectionName cellIdentifier:(NSString *)cellIdentifier data:(id)data;

/**
 Prefixes "data." to the given keyPath.
 */
+ (NSString *)keyPathForDataKeyPath:(NSString *)dataKeyPath;

/**
 Returns the array of identifiers for the given `NSIndexPathItems`
 */
+ (NSArray *)identifiersForIndexPathItems:(NSArray *)indexPathItems;

@end
