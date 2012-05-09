//
//  ESRootViewController.m
//  AccessibilitySuite
//
//  Created by Doug Russell
//  Copyright (c) Doug Russell. All rights reserved.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  	

#import "ASRootViewController.h"
#import "ASSegmentedControlViewController.h"
#import "ASButtonViewController.h"
#import "ASContainerViewController.h"
#import "ASSliderViewController.h"

@interface ASRootViewController () 

@end

@implementation ASRootViewController
@synthesize tableView=_tableView;

#pragma mark - Init / Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Accessibility Samples";
	}
	return self;
}

- (void)dealloc
{
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
}

#pragma mark - View Life Cycle

- (void)loadView
{
	[super loadView];
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	self.tableView = nil;
}

#pragma mark - Table View Data Source

enum {
	ButtonsRow,
	SegmentedControlRow,
	ContainerRow,
	SliderRow,
	NumberOfRows,
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return NumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reuseIdentifier = @"cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	switch (indexPath.row) {
		case ButtonsRow:
			[[cell textLabel] setText:@"Buttons"];
			break;
		case SegmentedControlRow:
			[[cell textLabel] setText:@"Segmented Controls"];
			break;
		case ContainerRow:
			[[cell textLabel] setText:@"Container"];
			break;
		case SliderRow:
			[[cell textLabel] setText:@"Sliders"];
			break;
		default:
			break;
	}
	return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UIViewController *controller;
	switch (indexPath.row) {
		case ButtonsRow:
			controller = [ASButtonViewController new];
			break;
		case SegmentedControlRow:
			controller = [ASSegmentedControlViewController new];
			break;
		case ContainerRow:
			controller = [ASContainerViewController new];
			break;
		case SliderRow:
			controller = [ASSliderViewController new];
			break;
		default:
			break;
	}
	if (controller)
		[self.navigationController pushViewController:controller animated:YES];
}

@end
