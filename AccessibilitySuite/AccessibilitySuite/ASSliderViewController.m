//
//  ASSliderViewController.m
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

#import "ASSliderViewController.h"
#import "ASPageSlider.h"
#import "ASCustomizedPageSlider.h"

@interface ASSliderViewController ()
@property (weak, nonatomic) IBOutlet UISlider *stockSlider;
@property (weak, nonatomic) IBOutlet ASPageSlider *pageSlider;
@property (weak, nonatomic) IBOutlet ASCustomizedPageSlider *customPageSlider;
- (IBAction)valueChanged:(id)sender;
@end

@implementation ASSliderViewController

#pragma mark - Init/Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Sliders";
	}
	return self;
}

- (IBAction)valueChanged:(id)sender
{
	NSLog(@"Value Changed");
}

@end
