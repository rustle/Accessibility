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
#import "ASAccessibilityElement.h"

@interface ASAccessibleImageView ()
@property (strong, nonatomic) NSMutableArray *accessibilityElements;
@end

@implementation ASAccessibleImageView

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
	return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
	return [self.accessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
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
	}
}

- (void)clearAccessibilityElements
{
	[self.accessibilityElements removeAllObjects];
}

@end
