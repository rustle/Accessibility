//
//  ASSegmentedControlViewController.m
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

#import "ASSegmentedControlViewController.h"

// Note of possible interest: 
// The segmented controls take their accessibility labels from their images
// which is why they're being manipulated in view did load.
// This demo uses IB and the nib loading logic can sometimes reuse
// the same UIImage instance, so it was necessary to add an extra copy
// of the segmented control images to demonstrate the case where
// labels are extracted from png file names.

@interface ASSegmentedControlViewController ()

@end

@implementation ASSegmentedControlViewController
@synthesize segmentedControlText=_segmentedControlText;
@synthesize segmentedControlImages=_segmentedControlImages;
@synthesize segmentedControlAccessibleImages=_segmentedControlAccessibleImages;

#pragma mark - Init/Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Segmented Controls";
	}
	return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.segmentedControlAccessibleImages imageForSegmentAtIndex:0].accessibilityLabel = @"Left";
	[self.segmentedControlAccessibleImages imageForSegmentAtIndex:1].accessibilityLabel = @"Right";
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.segmentedControlText = nil;
	self.segmentedControlImages = nil;
	self.segmentedControlImages = nil;
}
@end
