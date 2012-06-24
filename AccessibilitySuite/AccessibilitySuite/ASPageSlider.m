//
//  ASPageSlider.m
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

#import "ASPageSlider.h"

@interface ASPageSlider ()
- (void)updateAccessibilityValue;
@end

@implementation ASPageSlider

static void CommonInit(ASPageSlider *self)
{
	[self updateAccessibilityValue];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		CommonInit(self);
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		CommonInit(self);
	}
	return self;
}

- (void)awakeFromNib
{
	[self updateAccessibilityValue];
}

- (NSString *)accessibilityLabel
{
	return @"Page";
}

- (void)accessibilityIncrement
{
	self.value += 1.0f;
}

- (void)accessibilityDecrement
{
	self.value -= 1.0f;
}

- (void)setValue:(float)value animated:(BOOL)animated
{
	[super setValue:value animated:animated];
	[self updateAccessibilityValue];
}

- (void)updateAccessibilityValue
{
	self.accessibilityValue = [NSString stringWithFormat:@"%3.0f", self.value];
}

@end
