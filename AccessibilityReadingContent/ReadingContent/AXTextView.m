//
//  AXTextView.m
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

#import "AXTextView.h"
#import "AXTextView_Internal.h"

@implementation AXTextView

#pragma mark - 

- (NSAttributedString *)content
{
	// Rippped from wikipedia page on screen readers
	NSString *content = @"A screen reader is a software application that attempts to identify and interpret what is being displayed on the screen (or, more accurately, sent to standard output, whether a video monitor is present or not). This interpretation is then re-presented to the user with text-to-speech, sound icons, or a Braille output device. Screen readers are a form of assistive technology potentially useful to people who are blind, visually impaired, illiterate or learning disabled, often in combination with other assistive technology, such as screen magnifiers.";
	
	CTFontRef font = CTFontCreateWithName(CFSTR("HelveticaNeueLight"), 18, NULL);
	NSDictionary *attributes = nil;
	if (font)
	{
		attributes = [NSDictionary dictionaryWithObject:(__bridge id)font forKey:(id)kCTFontAttributeName];
		CFRelease(font);
	}
	
	return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		self.textInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
		self.attributedText = [self content];
	}
	return self;
}

- (void)dealloc
{
	self.frameRef = NULL;
}

#pragma mark -

- (void)setFrameRef:(CTFrameRef)frameRef
{
	if (frameRef != _frameRef)
	{
		if (_frameRef)
		{
			CFRelease(_frameRef);
		}
		if (frameRef)
		{
			CFRetain(frameRef);
		}
		_frameRef = frameRef;
	}
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
	if (attributedText != _attributedText)
	{
		_attributedText = attributedText;
		[self ax_reset];
	}
}

- (void)setTextInsets:(UIEdgeInsets)textInsets
{
	_textInsets = textInsets;
	[self setNeedsDisplay];
}

#pragma mark - 

- (void)ax_reset
{
	[self setNeedsDisplay];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self ax_reset];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Draw Text
	CGContextSaveGState(context);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	[self drawTextWithFramesetter:self.attributedText context:context];
	CGContextRestoreGState(context);
}

- (void)drawTextWithFramesetter:(NSAttributedString *)attributedString context:(CGContextRef)context
{
	if (attributedString == nil)
	{
		return;
	}
	// Draw our text inside a frame
	[self makeFrameWithAttributeString:attributedString];
	CTFrameDraw(self.frameRef, context);
}

- (void)makeFrameWithAttributeString:(NSAttributedString *)attributedString
{
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
	if (framesetter)
	{
		CFRange range = CFRangeMake(0, 0);
		CGRect rect = UIEdgeInsetsInsetRect(self.bounds, self.textInsets);
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
		CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, range, [path CGPath], NULL);
		if (frameRef)
		{
			self.frameRef = frameRef;
			CFRelease(frameRef);
			CFRelease(framesetter);
		}
	}
}

@end
