//
//  ASCustomizedPageSlider.m
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

#import "ASCustomizedPageSlider.h"

// IMPORTANT: Don't actually use this class, it's just a demonstration of how to make a custom slider accessible. Use UISlider, it's much better.

@interface ASCustomizedPageSlider ()
- (void)updateAccessibilityValue;
@end

@implementation ASCustomizedPageSlider

static void CommonInit(ASCustomizedPageSlider *self)
{
	self.value = 1.0f;
	self.minValue = 1.0f;
	self.maxValue = 20.0f;
	[self updateAccessibilityValue];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		CommonInit(self);
	}
	return self;
}

- (void)setValue:(float)value
{
	if (value < self.minValue)
		return;
	if (value > self.maxValue)
		return;
	_value = value;
	[self updateAccessibilityValue];
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

#define HandleSize 30.0f
#define HandleInset (HandleSize / 2.0f)

- (CGRect)handleRect
{
	CGSize size = self.bounds.size;
	CGFloat x = (size.width - HandleSize) * ((self.value - self.minValue) / (self.maxValue - self.minValue));
	return CGRectMake(x, CGRectGetMidY(self.bounds) - HandleInset, HandleSize, HandleSize);
}

- (void)drawRect:(CGRect)rect
{
	[[UIColor blackColor] set];
	UIRectFill(rect);
	[[UIColor grayColor] set];
	UIRectFill([self handleRect]);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];
	if (beginTracking)
	{
		CGPoint touchLocation = [touch locationInView:self];
		if ((touchLocation.x > 0.0f) ||
			(touchLocation.x < (self.bounds.size.width - HandleSize)))
		{
			CGRect handleRect = [self handleRect];
			if (!CGRectContainsPoint(handleRect, touchLocation))
				beginTracking = NO;
		}
		else
			beginTracking = NO;
	}
	return beginTracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL continueTracking = [super continueTrackingWithTouch:touch withEvent:event];
	if (continueTracking)
	{
		CGPoint touchLocation = [touch locationInView:self];
		if ((touchLocation.x > 0.0f) ||
			(touchLocation.x < (self.bounds.size.width - HandleSize)))
		{
			self.value = ((touchLocation.x - HandleInset) / (self.bounds.size.width - HandleSize)) * (self.maxValue - self.minValue);
		}
		else
			continueTracking = NO;
	}
	return continueTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	[super cancelTrackingWithEvent:event];
}

#pragma mark - 

- (BOOL)isAccessibilityElement
{
	return YES;
}

- (void)accessibilityIncrement
{
	self.value += 1.0f;
}

- (void)accessibilityDecrement
{
	self.value -= 1.0f;
}

- (UIAccessibilityTraits)accessibilityTraits
{
	UIAccessibilityTraits traits = [super accessibilityTraits];
	return (traits | UIAccessibilityTraitAdjustable);
}

- (NSString *)accessibilityLabel
{
	return @"Page"; // Ideally this would be localized
}

- (void)updateAccessibilityValue
{
	self.accessibilityValue = [NSString stringWithFormat:@"%3.0f", self.value];
}

@end
