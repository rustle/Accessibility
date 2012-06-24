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
#import "BPXLTextView+Private.h"

@interface BPXLTextView ()

@end

@implementation BPXLTextView

#pragma mark - Setup / Cleanup

static UIColor *whitish = nil;
static UIColor *bluish = nil;
+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		whitish = [UIColor colorWithWhite:0.0f alpha:1.0f];
		bluish = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
	});
}

static void CommonInit(BPXLTextView *self)
{
	// Initialization code
	self.backgroundColor = [UIColor whiteColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.textInset = CGPointMake(10.0f, 10.0f);
	self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self addGestureRecognizer:self.pan];
	self.circleCenter = CGPointMake(100.0f, 100.0f);
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
	self.circlePath = nil;
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
	if (self.circlePath == nil)
	{
		CGRect rect = CGRectInset(self.bounds, self.textInset.x, self.textInset.y);
		CGPoint origin = self.circleCenter;
		origin.x -= 100.0f;
		origin.y -= 100.0f;
		CGRect circleRect = (CGRect){ origin, (CGSize){ 200.0f, 200.0f } };
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, 0, rect.size.height + (2 * self.textInset.x) );
		transform = CGAffineTransformScale(transform, 1.0, -1.0);
		circleRect = CGRectApplyAffineTransform(circleRect, transform);
		self.circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
		[self.path appendPath:[self circlePath]];
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
	CGContextSetStrokeColorWithColor(context, whitish.CGColor);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextAddPath(context, self.path.CGPath);
	CGContextStrokePath(context);
	[self drawTextWithFramesetter:self.attributedString rect:rect path:self.path.CGPath context:context];
	CGContextRestoreGState(context);
	
	// Draw a circle
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetFillColorWithColor(context, bluish.CGColor);
	UIBezierPath *circlePath = [self circlePath];
	CGContextAddPath(context, circlePath.CGPath);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
}

- (void)drawTextWithFramesetter:(NSAttributedString *)attributedString rect:(CGRect)rect path:(CGPathRef)path context:(CGContextRef)context
{
	// Draw our text inside a frame
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
	CFRange range = CFRangeMake(0, 0);
	CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, range, path, NULL);
	self.frameRef = frameRef;
	CFRelease(frameRef);
	CTFrameDraw(self.frameRef, context);
	CFRelease(framesetter);
}

#pragma mark - Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self reset];
}

#pragma mark - 

- (void)pan:(UIPanGestureRecognizer *)pan
{
	self.path = nil;
	self.circlePath = nil;
	self.circleCenter = [pan locationInView:pan.view];
	[self setNeedsDisplay];
}

@end
