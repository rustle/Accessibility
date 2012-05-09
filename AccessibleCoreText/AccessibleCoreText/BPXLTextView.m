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

@interface BPXLTextView ()
@property (strong, nonatomic) UIBezierPath *path;
@property (strong, nonatomic) UIBezierPath *circlePath;
- (void)configurePath;
@property (strong, nonatomic) __attribute__((NSObject)) CTFrameRef frameRef;
- (void)drawTextWithFramesetter:(NSAttributedString *)attributedString rect:(CGRect)rect path:(CGPathRef)path context:(CGContextRef)context;
@property (strong, nonatomic) NSMutableArray *accessibilityElements;
- (void)resetAccessibilityElements;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (assign, nonatomic) CGPoint circleCenter;
@end

@implementation BPXLTextView
@synthesize attributedString=_attributedString;
@synthesize textInset=_textInset;
@synthesize path=_path;
@synthesize circlePath=_circlePath;
@synthesize accessibilityElements=_accessibilityElements;
@synthesize frameRef=_frameRef;
@synthesize pan=_pan;
@synthesize circleCenter=_circleCenter;

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

- (void)commonSetup
{
	// Initialization code
	self.backgroundColor = [UIColor whiteColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_textInset = CGPointMake(10.0f, 10.0f);
	_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self addGestureRecognizer:_pan];
	_circleCenter = CGPointMake(100.0f, 100.0f);
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self commonSetup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self commonSetup];
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
	[self resetAccessibilityElements];
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
		[self resetAccessibilityElements];
		self.frameRef = NULL;
		_attributedString = attributedString;
		[self setNeedsDisplay];
	}
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
	[self configurePath];
	[self resetAccessibilityElements];
	
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
	// Line bounds needs to be in screen coordinates, so convert rect to window
	CGRect lineBounds = [[self.accessibilityElements objectAtIndex:lineNumber] accessibilityFrame];
	UIWindow *window = [self window];
	lineBounds = [self convertRect:lineBounds toView:window];
	if (window != nil)
	{
		lineBounds = [window convertRect:lineBounds toWindow:nil];
	}
	return lineBounds;
}

// Returns a string representing the text displayed on the current page.
- (NSString *)accessibilityPageContent
{
	return self.attributedString.string;
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

#pragma mark - 

- (void)pan:(UIPanGestureRecognizer *)pan
{
	self.path = nil;
	self.circlePath = nil;
	self.circleCenter = [pan locationInView:pan.view];
	[self setNeedsDisplay];
}

@end
