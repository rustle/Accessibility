//
//  BPXLTextView.m
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

#import "BPXLTextView.h"
#import "BPXLTextView_Internal.h"

@interface BPXLTextView ()

@end

@implementation BPXLTextView

#pragma mark - Setup / Cleanup

static void CommonInit(BPXLTextView *self)
{
	// Initialization code
	self.backgroundColor = [UIColor whiteColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.textInset = CGPointMake(10.0f, 10.0f);
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

- (void)dealloc
{
	self.frameRef = NULL;
}

#pragma mark - 

- (void)reset
{
	self.frameRef = NULL;
	self.path = nil;
	[self setNeedsDisplay];
}

#pragma mark - 

- (void)setFrameRef:(CTFrameRef)frameRef
{
	if (frameRef != _frameRef)
	{
		if (_frameRef != NULL)
		{
			CFRelease(_frameRef);
		}
		if (frameRef != NULL)
		{
			CFRetain(frameRef);
		}
		_frameRef = frameRef;
	}
}

- (void)setTextInset:(CGPoint)textInset
{
	if (!CGPointEqualToPoint(textInset, _textInset))
	{
		_textInset = textInset;
		[self reset];
	}
}

- (void)configurePath
{
	if (self.path == nil)
	{
		CGRect rect = CGRectInset(self.bounds, self.textInset.x, self.textInset.y);
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
		self.path = path;
	}
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (attributedString != _attributedString)
	{
		self.frameRef = NULL;
		_attributedString = attributedString;
		[self setNeedsDisplay];
	}
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
	[self configurePath];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Draw Text
	CGContextSaveGState(context);
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextAddPath(context, self.path.CGPath);
	CGContextStrokePath(context);
	[self drawTextWithFramesetter:self.attributedString path:self.path.CGPath context:context];
	CGContextRestoreGState(context);
}

- (void)makeFrameWithAttributeString:(NSAttributedString *)attributedString path:(CGPathRef)path
{
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
	CFRange range = CFRangeMake(0, 0);
	CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, range, path, NULL);
	self.frameRef = frameRef;
	CFRelease(frameRef);
	CFRelease(framesetter);
}

- (void)drawTextWithFramesetter:(NSAttributedString *)attributedString path:(CGPathRef)path context:(CGContextRef)context
{
	if (attributedString == nil)
		return;
	// Draw our text inside a frame
	[self makeFrameWithAttributeString:attributedString path:path];
	CTFrameDraw(self.frameRef, context);
}

#pragma mark - Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self reset];
}

@end
