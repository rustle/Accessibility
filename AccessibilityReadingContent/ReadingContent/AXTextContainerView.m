//
//  AXTextContainerView.m
//  ReadingContent
//
//  Created by Doug Russell on 9/12/13.
//  Copyright (c) 2013 Doug Russell. All rights reserved.
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

#import "AXTextContainerView.h"
#import "AXTextView_Internal.h"

@interface AXTextContainerView ()
@property (nonatomic) NSMutableArray *axTextElements;
@end

@implementation AXTextContainerView

#pragma mark - Reset

- (void)reset
{
	[self ax_resetAccessibilityElements];
	[super ax_reset];
}

#pragma mark - Accessibility Elements

- (void)ax_resetAccessibilityElements
{
	self.axTextElements = nil;
}

- (void)ax_configureAccessibilityElements
{
	if (!self.axTextElements)
	{
		// If we don't have a frame ref, we don't have any lines
		if (self.frameRef == NULL)
		{
			return;
		}
		UIWindow *window = self.window;
		if (window == nil)
		{
			
		}
		self.axTextElements = [NSMutableArray new];
		CGRect rect = self.bounds;
		// Get the lines out of the current frame and the lines origins
		CFArrayRef lines = CTFrameGetLines(self.frameRef);
		CFIndex count = CFArrayGetCount(lines);
		CGPoint *origins = malloc(sizeof(CGPoint) * count);
		CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, count), origins);
		UIEdgeInsets textInsets = self.textInsets;
		for (CFIndex i = 0; i < count; i++)
		{
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			// Get the lines substring
			CFRange cfRange = CTLineGetStringRange(line);
			NSRange range = NSMakeRange(cfRange.location, cfRange.length);
			NSString *string = [self.attributedText.string substringWithRange:range];
			// Get the lines geometry
			CGFloat ascent, descent, leading;
			double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
			CGFloat height = ascent + descent + leading;
			// Skips lines that are just line breaks
			if (string.length == 1 && [string isEqualToString:@"\n"])
			{
				continue;
			}
			// Adjust the lines origin for top left origin instead of bottotm left origin
			CGPoint adjustedOrigin = origins[i];
			adjustedOrigin.y = rect.size.height - adjustedOrigin.y - height - textInsets.top;
			adjustedOrigin.x += textInsets.left;
			CGRect frame = (CGRect){ adjustedOrigin, (CGSize) { (CGFloat)width, height} };
			frame = [self convertRect:frame toView:window];
			frame = [window convertRect:frame toWindow:nil];
			// Build accessibility element
			UIAccessibilityElement *accElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
			accElement.isAccessibilityElement = YES;
			accElement.accessibilityLabel = string;
			accElement.accessibilityFrame = frame;
			// Traits is a bitmask so don't for get to | in the default traits
			accElement.accessibilityTraits = accElement.accessibilityTraits | UIAccessibilityTraitStaticText;
			[self.axTextElements addObject:accElement];
		}
		free(origins);
	}
}

#pragma mark - Accessibility Container

/*
 Return YES if the receiver should be exposed as an accessibility element. 
 default == NO
 default on UIKit controls == YES 
 Setting the property to YES will cause the receiver to be visible to assistive applications. 
 */
- (BOOL)isAccessibilityElement
{
	// Containers are not themselves accessibility elements
	return NO;
}

/*
 Returns the number of accessibility elements in the container.
 */
- (NSInteger)accessibilityElementCount
{
	[self ax_configureAccessibilityElements];
	return (NSInteger)[self.axTextElements count];
}

/*
 Returns the accessibility element in order, based on index.
 default == nil 
 */
- (id)accessibilityElementAtIndex:(NSInteger)index
{
	[self ax_configureAccessibilityElements];
	return [self.axTextElements objectAtIndex:index];
}

/*
 Returns the ordered index for an accessibility element
 default == NSNotFound 
 */
- (NSInteger)indexOfAccessibilityElement:(id)element
{
	[self ax_configureAccessibilityElements];
	return [self.axTextElements indexOfObject:element];
}

@end
