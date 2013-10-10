//
//  ViewController.m
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"

@interface ViewController ()
@property (strong, nonatomic) CollectionViewController *collectionViewController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionViewController.useTransitionLayout = self.transitionLayoutSwitch.isOn;
    self.durationSlider.minimumValue = 0.05;
    self.durationSlider.maximumValue = 2.0;
    self.durationSlider.value = 0.25;
    self.collectionViewController.duration = self.durationSlider.value;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.collectionViewController = (CollectionViewController *)segue.destinationViewController;
}

- (IBAction)transitionLayoutSwitchChanged:(UISwitch *)sender {
    self.collectionViewController.useTransitionLayout = sender.isOn;
    self.durationSlider.enabled = sender.isOn;
}

- (IBAction)durationChanged:(UISlider *)sender {
    self.collectionViewController.duration = sender.value;
}

@end
