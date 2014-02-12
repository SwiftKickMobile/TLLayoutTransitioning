//
//  ViewController.h
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResizeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *transitionLayoutSwitch;
@property (strong, nonatomic) IBOutlet UISlider *durationSlider;
- (IBAction)transitionLayoutSwitchChanged:(UISwitch *)sender;
- (IBAction)durationChanged:(UISlider *)sender;
@end
