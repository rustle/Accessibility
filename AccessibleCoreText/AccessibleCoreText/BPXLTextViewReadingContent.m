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
#import "BPXLTextView_Internal.h"

@interface BPXLTextViewReadingContent ()
@property (nonatomic) NSMutableArray *accessibilityElements;
- (void)resetAccessibilityElements;
- (void)configureAccessibilityElements;
@end

@implementation BPXLTextViewReadingContent

#pragma mark - Reset

- (void)reset
{
	[self resetAccessibilityElements];
	[super reset];
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
			[self makeFrameWithAttributeString:self.attributedString path:self.path.CGPath];
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

#pragma mark - Accessibility Reading Content

- (BOOL)isAccessibilityElement
{
	return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
	if (self.causesPageTurn)
		return [super accessibilityTraits] | UIAccessibilityTraitCausesPageTurn;
	return [super accessibilityTraits];
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
	CGRect frame = [[self.accessibilityElements objectAtIndex:lineNumber] accessibilityFrame];
	UIWindow *window = self.window;
	frame = [self convertRect:frame toView:window];
	if (window)
		frame = [window convertRect:frame toWindow:nil];
	return frame;
}

// Returns a string representing the text displayed on the current page.
- (NSString *)accessibilityPageContent
{
	[self configureAccessibilityElements];
	return self.attributedString.string;
}

@end
