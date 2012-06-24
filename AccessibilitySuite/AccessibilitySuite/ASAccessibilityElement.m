//
//  ASAccessibilityElement.m
//  AccessibilitySuite
//
//  Created by Doug Russell on 6/24/12.
//
//

#import "ASAccessibilityElement.h"

@implementation ASAccessibilityElement
{
	bool hasViewContainer;
}

- (instancetype)initWithAccessibilityContainer:(id)container
{
	self = [super initWithAccessibilityContainer:container];
	if (self)
	{
		hasViewContainer = [container isKindOfClass:[UIView class]];
	}
	return self;
}

- (CGRect)accessibilityFrame
{
	if (!hasViewContainer)
		return [super accessibilityFrame];
	// accessibilityFrame is in screen coordinates, so do some hoop jumping to convert
	UIWindow *window = [[self accessibilityContainer] window];
	if (window == nil)
		return self.frameRelativeToContainer;
	CGRect frame = self.frameRelativeToContainer;
	frame = [[self accessibilityContainer] convertRect:frame toView:window];
	frame = [window convertRect:frame toWindow:nil];
	return frame;
}

@end
