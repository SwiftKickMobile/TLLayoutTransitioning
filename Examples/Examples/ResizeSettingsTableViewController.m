//
//  ViewController.m
//  Collection
//
//  Created by Tim Moose on 10/9/13.
//  Copyright (c) 2013 wtm@tractablelabs.com. All rights reserved.
//

#import "ResizeSettingsTableViewController.h"
#import "ResizeCollectionViewController.h"
#import <AHEasing/easing.h>

@interface ResizeSettingsTableViewController ()
@property (strong, nonatomic) ResizeCollectionViewController *collectionViewController;
@property (strong, nonatomic) TLIndexPathDataModel *easingCurveDataModel;
@end

@implementation ResizeSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSegueWithIdentifier:@"ResizeExampleDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.collectionViewController = (ResizeCollectionViewController *)segue.destinationViewController;
    [self initialize];
}

- (void)initialize
{
    if (self.isViewLoaded && self.collectionViewController) {
        // duration
        self.durationSlider.minimumValue = 0.05;
        self.durationSlider.maximumValue = 2.0;
        self.durationSlider.value = .75;
        [self updateDuration];
        
        // target content offset
        self.toContentOffset.apportionsSegmentWidthsByContent = YES;
        self.toContentOffset.selectedSegmentIndex = 2;
        [self updateToContentOffset];
        
        // easing curve
        self.easingCurvePicker.dataSource = self;
        self.easingCurvePicker.delegate = self;
        self.easingCurveDataModel = [self newEasingCurveDataModel];
        [self.easingCurvePicker selectRow:5 inComponent:0 animated:NO];
        [self.easingCurvePicker selectRow:2 inComponent:1 animated:NO];
        [self updateEasingCurve];
        
        // section headers
        self.collectionViewController.showSectionHeaders = self.showSectionHeaders.isOn;
    }
}

#pragma mark - Duration

- (IBAction)durationChanged:(UISlider *)sender {
    [self updateDuration];
}

- (void)updateDuration
{
    self.collectionViewController.duration = self.durationSlider.value;
    self.durationLabel.text = [NSString stringWithFormat:@"%.2f seconds", self.durationSlider.value];
}

#pragma mark - Target content offset

- (void)toContentOffsetChanged:(UISegmentedControl *)sender
{
    [self updateToContentOffset];
}

- (void)updateToContentOffset
{
    NSNumber *placement = [@[@(TLTransitionLayoutIndexPathPlacementMinimal),
                                   @(TLTransitionLayoutIndexPathPlacementVisible),
                                   @(TLTransitionLayoutIndexPathPlacementCenter),
                                   @(TLTransitionLayoutIndexPathPlacementTop),
                                   @(TLTransitionLayoutIndexPathPlacementBottom)]
                                 objectAtIndex:self.toContentOffset.selectedSegmentIndex];
    self.collectionViewController.toContentOffset = [placement integerValue];
}

#pragma mark - Easing curve

- (void)updateEasingCurve
{
    NSInteger selectedCurve = [self.easingCurvePicker selectedRowInComponent:0];
    NSInteger selectedEasing = [self.easingCurvePicker selectedRowInComponent:1];
    NSIndexPath *curveIndexPath = [NSIndexPath indexPathForRow:selectedCurve inSection:0];
    TLIndexPathItem *curveItem = [self.easingCurveDataModel itemAtIndexPath:curveIndexPath];
    NSValue *easingValue = curveItem.data[selectedEasing];
    self.collectionViewController.easingFunction = [easingValue pointerValue];
}

- (TLIndexPathDataModel *)newEasingCurveDataModel
{
    NSMutableArray *curveItems = [NSMutableArray arrayWithCapacity:10];
    [curveItems addObject:curveItem(@"Linear", LinearInterpolation, LinearInterpolation, LinearInterpolation)];
    [curveItems addObject:curveItem(@"Exponential", ExponentialEaseIn, ExponentialEaseOut, ExponentialEaseInOut)];
    [curveItems addObject:curveItem(@"Bounce", BounceEaseIn, BounceEaseOut, BounceEaseInOut)];
    [curveItems addObject:curveItem(@"Quadratic", QuadraticEaseIn, QuadraticEaseOut, QuadraticEaseInOut)];
    [curveItems addObject:curveItem(@"Cubic", CubicEaseIn, CubicEaseOut, CubicEaseInOut)];
    [curveItems addObject:curveItem(@"Quartic", QuarticEaseIn, QuarticEaseOut, QuarticEaseInOut)];
    [curveItems addObject:curveItem(@"Quintic", QuinticEaseIn, QuinticEaseOut, QuinticEaseInOut)];
    [curveItems addObject:curveItem(@"Sine", SineEaseIn, SineEaseOut, SineEaseInOut)];
    [curveItems addObject:curveItem(@"Circular", CircularEaseIn, CircularEaseOut, CircularEaseInOut)];
    [curveItems addObject:curveItem(@"Elastic", ElasticEaseIn, ElasticEaseOut, ElasticEaseInOut)];
    [curveItems addObject:curveItem(@"Back", BackEaseIn, BackEaseOut, BackEaseInOut)];
    TLIndexPathSectionInfo *curvesSection = [[TLIndexPathSectionInfo alloc] initWithItems:curveItems name:@"Curves"];
    TLIndexPathSectionInfo *easingSection = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"EaseIn", @"EaseOut", @"EaseInOut"] name:@"Easing"];
    return [[TLIndexPathDataModel alloc] initWithSectionInfos:@[curvesSection, easingSection] identifierKeyPath:nil];
}

TLIndexPathItem *curveItem(NSString *name, AHEasingFunction inFunc, AHEasingFunction outFunc, AHEasingFunction inOutFunc)
{
    NSValue *inValue = [NSValue valueWithPointer:inFunc];
    NSValue *outValue = [NSValue valueWithPointer:outFunc];
    NSValue *inOutValue = [NSValue valueWithPointer:inOutFunc];
    return [[TLIndexPathItem alloc] initWithIdentifier:name sectionName:nil cellIdentifier:nil data:@[inValue, outValue, inOutValue]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.easingCurveDataModel.numberOfSections;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.easingCurveDataModel numberOfRowsInSection:component];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.easingCurveDataModel identifierAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateEasingCurve];
}

#pragma mark - Sections

- (IBAction)showSectionHeadersChanged:(UISwitch *)sender {
    self.collectionViewController.showSectionHeaders = sender.isOn;
}

@end
