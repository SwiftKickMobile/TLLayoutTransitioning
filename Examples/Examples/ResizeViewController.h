//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResizeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *toContentOffset;
@property (strong, nonatomic) IBOutlet UISegmentedControl *easingCurve;
@property (strong, nonatomic) IBOutlet UISlider *durationSlider;
- (IBAction)durationChanged:(UISlider *)sender;
- (IBAction)toContentOffsetChanged:(UISegmentedControl *)sender;
- (IBAction)easingCurveChanged:(UISegmentedControl *)sender;
@end
