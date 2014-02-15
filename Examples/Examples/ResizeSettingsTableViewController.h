//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TLIndexPathTools/TLTableViewController.h>

@interface ResizeSettingsTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *toContentOffset;
@property (strong, nonatomic) IBOutlet UIPickerView *easingCurvePicker;
@property (strong, nonatomic) IBOutlet UISlider *durationSlider;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
- (IBAction)durationChanged:(UISlider *)sender;
- (IBAction)toContentOffsetChanged:(UISegmentedControl *)sender;
@end
