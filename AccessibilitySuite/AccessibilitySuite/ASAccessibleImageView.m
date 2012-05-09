//
//  ASAccessibleImageView.m
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

#import "ASAccessibleImageView.h"

@interface ASAccessibilityElement : UIAccessibilityElement
@property (assign, nonatomic) CGRect frameRelativeToContainer;
@end

@implementation ASAccessibilityElement
@synthesize frameRelativeToContainer=_frameRelativeToContainer;
@end

@interface ASAccessibleImageView ()
{
	BOOL accessibilityElementsDirty;
}
@property (strong, nonatomic) NSMutableArray *accessibilityElements;
- (void)updateAccessibilityFramesIfNeeded;
@end

@implementation ASAccessibleImageView
@synthesize accessibilityElements=_accessibilityElements;

#pragma mark - Init/Dealloc

- (void)commonInit
{
	
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self commonInit];
	}
	return self;
}

#pragma mark - Accessors

- (BOOL)isAccessibilityElement
{
	return NO;
}

- (NSMutableArray *)accessibilityElements
{
	if (_accessibilityElements == nil)
	{
		_accessibilityElements = [NSMutableArray new];
	}
	return _accessibilityElements;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger)accessibilityElementCount
{
	[self updateAccessibilityFramesIfNeeded];
	return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
	[self updateAccessibilityFramesIfNeeded];
	return [self.accessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
	[self updateAccessibilityFramesIfNeeded];
	return [self.accessibilityElements indexOfObject:element];
}

#pragma mark - Public

- (void)addAccessibilityElement:(NSString *)label hint:(NSString *)hint frame:(CGRect)frame
{
	if (!label.length)
	{
		return;
	}
	ASAccessibilityElement *accElement = [[ASAccessibilityElement alloc] initWithAccessibilityContainer:self];
	if (accElement)
	{
		accElement.frameRelativeToContainer = frame;
		accElement.accessibilityLabel = label;
		accElement.accessibilityHint = hint;
		accElement.accessibilityTraits = UIAccessibilityTraitStaticText;
		[self.accessibilityElements addObject:accElement];
		[self markAccessibilityElementsDirty];
	}
}

- (void)clearAccessibilityElements
{
	[self.accessibilityElements removeAllObjects];
}

- (void)markAccessibilityElementsDirty
{
	accessibilityElementsDirty = YES;
}

- (void)updateAccessibilityFramesIfNeeded
{
	if (!accessibilityElementsDirty)
	{
		return;
	}
	
	UIWindow *window = [self window];
	if (window == nil)
	{
		// If we don't have a window then we can't calculate our frames, so bail
		return;
	}
	
	for (ASAccessibilityElement *accElement in self.accessibilityElements)
	{
		// accessibilityFrames are in screen coordinates, so do some hoop jumping to convert
		CGRect frame = accElement.frameRelativeToContainer;
		frame = [self convertRect:frame toView:window];
		frame = [window convertRect:frame toWindow:nil];
		accElement.accessibilityFrame = frame;
	}
}

// Changes in super view or geometry invalidate the current accessibilityFrames

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self markAccessibilityElementsDirty];
}

- (void)setCenter:(CGPoint)center
{
	[super setCenter:center];
	[self markAccessibilityElementsDirty];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	[self markAccessibilityElementsDirty];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	[super willMoveToWindow:newWindow];
	[self markAccessibilityElementsDirty];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	[self markAccessibilityElementsDirty];
}

@end
