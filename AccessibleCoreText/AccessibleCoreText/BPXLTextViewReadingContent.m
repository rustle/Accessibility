//
//  BPXLTextViewReadingContent.m
//  AccessibleCoreText
//
//  Created by Doug Russell on 3/22/12.
//  Copyright (c) 2012 Black Pixel. All rights reserved.
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

#import "BPXLTextViewReadingContent.h"
#import "BPXLTextView+Private.h"
#import "BPXLTextViewContainer+Private.h"

@implementation BPXLTextViewReadingContent

#pragma mark - Accessibility Reading Content

- (UIAccessibilityTraits)accessibilityTraits
{
	return [super accessibilityTraits] | UIAccessibilityTraitCausesPageTurn;
}

// Returns the line number given a point in the view's coordinate space.
- (NSInteger)accessibilityLineNumberForPoint:(CGPoint)point
{
	[self configureAccessibilityElements];
	for (int i = 0; i < self.accessibilityElements.count; i++)
	{
		UIAccessibilityElement *accElement = [self.accessibilityElements objectAtIndex:i];
		if (CGRectContainsPoint(accElement.accessibilityFrame, point))
		{
			return i;
		}
	}
	return NSNotFound;
}

// Returns the content associated with a line number as a string.
- (NSString *)accessibilityContentForLineNumber:(NSInteger)lineNumber
{
	[self configureAccessibilityElements];
	return [[self.accessibilityElements objectAtIndex:lineNumber] accessibilityLabel];
}

// Returns the on-screen rectangle for a line number.
- (CGRect)accessibilityFrameForLineNumber:(NSInteger)lineNumber
{
	[self configureAccessibilityElements];
	return [[self.accessibilityElements objectAtIndex:lineNumber] accessibilityFrame];
}

// Returns a string representing the text displayed on the current page.
- (NSString *)accessibilityPageContent
{
	return self.attributedString.string;
}

@end
