//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLIndexPathTools.h>

@interface ResizeSettingsTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *toContentOffset;
@property (weak, nonatomic) IBOutlet UIPickerView *easingCurvePicker;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showSectionHeaders;
- (IBAction)durationChanged:(UISlider *)sender;
- (IBAction)toContentOffsetChanged:(UISegmentedControl *)sender;
- (IBAction)showSectionHeadersChanged:(UISwitch *)sender;
@end
