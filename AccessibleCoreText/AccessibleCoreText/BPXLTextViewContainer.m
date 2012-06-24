//
//  BPXLTextViewContainer.m
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

#import "BPXLTextViewContainer.h"
#import "BPXLTextView+Private.h"
#import "BPXLTextViewContainer+Private.h"

@implementation BPXLTextViewContainer

#pragma mark - 

- (void)reset
{
	[self resetAccessibilityElements];
	[super reset];
}

#pragma mark - Attributed String

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	[self resetAccessibilityElements];
	[super setAttributedString:attributedString];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
	[self resetAccessibilityElements];
	[super drawRect:rect];
}

#pragma mark - Accessibility Elements

- (void)resetAccessibilityElements
{
	self.accessibilityElements = nil;
}

- (void)configureAccessibilityElements
{
	if (self.accessibilityElements == nil)
	{
		// If we don't have a frame ref, we don't have any lines
		if (self.frameRef == NULL)
			return;
		UIWindow *window = self.window;
		if (window == nil)
			return;
		self.accessibilityElements = [NSMutableArray new];
		CGRect rect = self.bounds;
		// Get the lines out of the current frame and the lines origins
		CFArrayRef lines = CTFrameGetLines(self.frameRef);
		CFIndex count = CFArrayGetCount(lines);
		CGPoint *origins = malloc(sizeof(CGPoint) * count);
		CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, count), origins);
		for (CFIndex i = 0; i < count; i++)
		{
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			// Get the lines substring
			CFRange cfRange = CTLineGetStringRange(line);
			NSRange range = NSMakeRange(cfRange.location, cfRange.length);
			NSString *string = [self.attributedString.string substringWithRange:range];
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
			adjustedOrigin.y = rect.size.height - adjustedOrigin.y - height;
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
			[self.accessibilityElements addObject:accElement];
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
- (NSUInteger)accessibilityElementCount
{
	[self configureAccessibilityElements];
	return self.accessibilityElements.count;
}

/*
 Returns the accessibility element in order, based on index.
 default == nil 
 */
- (id)accessibilityElementAtIndex:(NSInteger)index
{
	[self configureAccessibilityElements];
	return [self.accessibilityElements objectAtIndex:index];
}

/*
 Returns the ordered index for an accessibility element
 default == NSNotFound 
 */
- (NSInteger)indexOfAccessibilityElement:(id)element
{
	[self configureAccessibilityElements];
	return [self.accessibilityElements indexOfObject:element];
}

#pragma mark - Accessibility Scroll

/*
 If the user interface requires a scrolling action (e.g. turning the page of a book), a view in the view 
 hierarchy should implement the following method. The return result indicates whether the action 
 succeeded for that direction. If the action failed, the method will be called on a view higher 
 in the hierarchy. If the action succeeds, UIAccessibilityPageScrolledNotification must be posted after
 the scrolling completes.
 default == NO
 */
- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
	self.path = nil;
	self.circlePath = nil;
	BOOL handled = NO;
	switch (direction) {
		case UIAccessibilityScrollDirectionDown:
			if (self.circleCenter.y > 100.0f)
			{
				self.circleCenter = CGPointMake(self.circleCenter.x, self.circleCenter.y - 100.0f);
				handled = YES;
			}
			break;
		case UIAccessibilityScrollDirectionUp:
			if (self.circleCenter.y < self.bounds.size.height - 100.0f)
			{
				self.circleCenter = CGPointMake(self.circleCenter.x, self.circleCenter.y + 100.0f);
				handled = YES;
			}
			break;
		case UIAccessibilityScrollDirectionLeft:
			if (self.circleCenter.x > 100.0f)
			{
				self.circleCenter = CGPointMake(self.circleCenter.x - 100.0f, self.circleCenter.y);
				handled = YES;
			}
			break;
		case UIAccessibilityScrollDirectionRight:
			if (self.circleCenter.x < self.bounds.size.width - 100.0f)
			{
				self.circleCenter = CGPointMake(self.circleCenter.x + 100.0f, self.circleCenter.y);
				handled = YES;
			}
			break;
		case UIAccessibilityScrollDirectionNext:
		case UIAccessibilityScrollDirectionPrevious:
			// If this code had more than one page, this is how you'd know to go to the next page
			break;
		default:
			break;
	}
	if (handled)
	{
		UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, [NSString stringWithFormat:@"The circle is now centered at %d by %d", (int)self.circleCenter.x, (int)self.circleCenter.y]);
		[self setNeedsDisplay];
	}
	return handled;
}

@end
