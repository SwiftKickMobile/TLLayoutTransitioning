//
//  TLDynamicHeightCell.h
//  TLIndexPathTools
//
//  Created by Tim Moose on 4/8/15.
//  Copyright (c) 2015 Tractable Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLDynamicSizeView.h"

/*
 Table view cells can use this base class in conjunction with
 TLTableViewController to automatically get the TLIndexPathTools
 implementation of dynamic height calculation (which is fully compatible
 with Auto Layout).
 */

@interface TLDynamicHeightCell : UITableViewCell <TLDynamicSizeView>

@end
