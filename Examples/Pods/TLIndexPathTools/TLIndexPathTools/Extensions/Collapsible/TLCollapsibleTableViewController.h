//
//  TLCollapsibleTableViewController.h
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

#import "TLTableViewController.h"
#import "TLCollapsibleDataModel.h"
#import "TLCollapsibleHeaderView.h"

@class TLCollapsibleTableViewController;

@protocol TLCollapsibleTableViewControllerDelegate <NSObject>
@optional
- (void)controller:(TLCollapsibleTableViewController *)controller didChangeSection:(NSInteger)section collapsed:(BOOL)collapsed;
@end

@interface TLCollapsibleTableViewController : TLTableViewController

@property (weak, nonatomic) id<TLCollapsibleTableViewControllerDelegate>delegate;

/**
 A type-safe shortcut for getting and setting the collapsible data model on the
 underlying index path controller.
 */
@property (strong, nonatomic) TLCollapsibleDataModel *dataModel;

/**
 If YES, exanding a section collapses all other sections. The default value of NO
 is recommended for better overall usability.
 */
@property (nonatomic) BOOL singleExpandedSection;

/**
 If YES, expanding a section scrolls the table view to display as many rows in the
 section as possible. Defaults to YES.
 */
@property (nonatomic) BOOL optimizeScrollOnExpand;

/**
 */
- (void)configureHeaderView:(TLCollapsibleHeaderView *)headerView forSection:(NSInteger)section;

@end
