//
//  TLDynamicHeightLabelCell.h
//  Dynamic Height Label Cell
//
//  Created by Tim Moose on 5/31/13.
//  Copyright (c) 2013 Tractable Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TLDynamicSizeView.h"

@interface TLDynamicHeightLabelCell : UITableViewCell <TLDynamicSizeView>
@property (strong, nonatomic) IBOutlet UILabel *label;
- (void)configureWithText:(NSString *)text;
@end
