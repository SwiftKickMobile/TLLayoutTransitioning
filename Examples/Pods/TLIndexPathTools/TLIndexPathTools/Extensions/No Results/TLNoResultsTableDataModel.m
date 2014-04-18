//
//  TLNoResultsTableDataModel.m
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

#import "TLNoResultsTableDataModel.h"
#import "TLIndexPathItem.h"

@implementation TLNoResultsTableDataModel

- (id)initWithRows:(NSInteger)rows blankCellId:(NSString *)blankCellId noResultsCellId:(NSString *)noResultsCellId noResultsText:(NSString *)noResultsText
{
    rows = MAX(rows, 1);
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:rows];
    for (NSInteger i = 0; i < rows; i++) {
        NSString *identifier = [NSString stringWithFormat:@"%d", (int)i];
        if (i == rows-1) {
            TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:nil cellIdentifier:noResultsCellId data:noResultsText];
            [items addObject:item];
        } else {
            TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:nil cellIdentifier:blankCellId data:nil];
            [items addObject:item];
        }
    }
    return [self initWithItems:items];
}

@end
