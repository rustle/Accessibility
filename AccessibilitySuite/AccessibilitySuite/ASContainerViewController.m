//
//  ASContainerViewController.m
//  AccessibilitySuite
//
//  Created by Doug Russell
//  Copyright (c) 2012 Doug Russell. All rights reserved.
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

#import "ASContainerViewController.h"
#import "ASAccessibleImageView.h"

@interface ASContainerViewController ()
@property (nonatomic) ASAccessibleImageView *imageView;
@end

@implementation ASContainerViewController

#pragma mark - Init/Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Container";
	}
	return self;
}

#pragma mark - View Life Cycle

- (void)loadView
{
	[super loadView];
	self.imageView = [[ASAccessibleImageView alloc] initWithFrame:self.view.bounds];
	self.imageView.contentMode = UIViewContentModeCenter;
	self.imageView.image = [UIImage imageNamed:@"Shapes"];
	if (ISIPAD)
	{
		[self.imageView addAccessibilityElement:@"Triangle" hint:@"Picture of a triangle" frame:CGRectMake(520.0f, 120.0f, 120.0f, 120.0f)];
		[self.imageView addAccessibilityElement:@"Square" hint:@"Picture of a square" frame:CGRectMake(140.0f, 770.0f, 130.0f, 130.0f)];
	}
	else
	{
		[self.imageView addAccessibilityElement:@"Triangle" hint:@"Picture of a triangle" frame:CGRectMake(30.0f, 50.0f, 120.0f, 120.0f)];
		[self.imageView addAccessibilityElement:@"Square" hint:@"Picture of a square" frame:CGRectMake(170.0f, 230.0f, 130.0f, 130.0f)];
	}
	[self.view addSubview:self.imageView];
}

@end
