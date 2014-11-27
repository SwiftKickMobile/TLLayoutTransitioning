//
//  TLDynamicSizeView.h
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
 Table view cells that implement this protocol will have their dynamic heights
 calculated automatically by `TLTableViewController` in its 
 `heightForRow:atIndexPath` implementation.
 
 With Auto Layout, the protocol should only be used as a marker to tell
 `TLTableViewController` to calculate the dynamic height. The `sizeWithData`
 method should not be implemented. In the `TLTableViewController` subclass,
 cell configuration should be one in `tableView:configureCell:atIndexPath:`
 because the `heightForRow:atIndexPath` implementation needs to configure
 a prototype instance before calculating the height. See the Dynamic Height
 example project.
 
 If Auto Layout is not being used, the `sizeWithData` method should be implemented.
 */

#import <Foundation/Foundation.h>

@protocol TLDynamicSizeView <NSObject>
@optional
/**
 Returns the computed size of the view for the given data. This method only needs
 to be implemented when Auto Layout is not being used.
 
 @param data  data that affects the view's size
 @return the computed size of the view
 */
- (CGSize) sizeWithData:(id)data;
@end
