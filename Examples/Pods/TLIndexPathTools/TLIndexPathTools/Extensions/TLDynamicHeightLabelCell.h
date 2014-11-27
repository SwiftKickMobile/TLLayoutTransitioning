//
//  TLDynamicHeightLabelCell.h
//  Dynamic Height Label Cell
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

/**
 Note that this class is not necessary with Auto Layout because TLIndexPathTools
 can calculate the height of Auto Layout cells automatically without any help.
 To enable this automatic behavior, see the comments in `TLDynamicSizeView`.
 */

#import <UIKit/UIKit.h>

#import "TLDynamicSizeView.h"

@interface TLDynamicHeightLabelCell : UITableViewCell <TLDynamicSizeView>
@property (weak, nonatomic) IBOutlet UILabel *label;
- (void)configureWithText:(NSString *)text;
@end
