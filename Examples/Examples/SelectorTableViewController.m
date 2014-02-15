//
//  ViewController.m
//  Examples
//
//  Created by Tim Moose on 2/11/14.
//  Copyright (c) 2014 Tractable Labs. All rights reserved.
//

#import "SelectorTableViewController.h"

@implementation SelectorTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.indexPathController.items = @[
                                       @"PinchExample",
                                       @"ResizeExample",
                                       ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSegueWithIdentifier:@"MainDetail" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.textLabel.text = item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.indexPathController.dataModel identifierAtIndexPath:indexPath];
    [self performSegueWithIdentifier:identifier sender:self];
}

@end
