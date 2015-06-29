//
//  ViewController.m
//  Examples
//
//  Created by Tim Moose on 2/11/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import "SelectorTableViewController.h"
#import <TLIndexPathTools/TLIndexPathTools.h>

@implementation SelectorTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TLIndexPathItem *resizeItem = [[TLIndexPathItem alloc] initWithIdentifier:@"Resize"
                                                                  sectionName:nil
                                                               cellIdentifier:nil
                                                                         data:@"Animated, non-interactive transitioning between layouts with duration, easing curves and content offset control. A better alternative to setCollectionViewLayout. Also demonstrates the use of the progressChanged callback to scale the font size."];

    TLIndexPathItem *pinchItem = [[TLIndexPathItem alloc] initWithIdentifier:@"Pinch"
                                                                  sectionName:nil
                                                               cellIdentifier:nil
                                                                        data:@"Simple interactive pinch transition with content offset control."];    
    self.indexPathController.items = @[resizeItem, pinchItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSegueWithIdentifier:@"MainDetail" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    TLIndexPathItem *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:2];
    textLabel.text = item.identifier;
    detailLabel.text = item.data;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.indexPathController.dataModel identifierAtIndexPath:indexPath];
    [self performSegueWithIdentifier:identifier sender:self];
}

@end
