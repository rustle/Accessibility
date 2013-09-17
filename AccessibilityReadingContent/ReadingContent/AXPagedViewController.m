//
//  AXPagedViewController.m
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

#import "AXPagedViewController.h"
#import "AXTextViewController.h"

@interface AXPagedViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSArray *viewControllers;
@end

@implementation AXPagedViewController

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:@"PageViewControllerSegue"])
	{
		self.pageViewController = segue.destinationViewController;
		
		UIStoryboard *storyboard = self.storyboard;
		// Store our view controller pages
		self.viewControllers = 
		@[
		  [storyboard instantiateViewControllerWithIdentifier:@"ReadingContentTextViewController"], 
		  [storyboard instantiateViewControllerWithIdentifier:@"ReadingContentTextViewController"], 
		  [storyboard instantiateViewControllerWithIdentifier:@"ReadingContentTextViewController"], 
		  ];
		[[self.viewControllers lastObject] setIsLastPage:YES];
		
		self.pageViewController.dataSource = self;
		self.pageViewController.delegate = self;
		
		self.pageViewController.view.backgroundColor = [UIColor lightGrayColor];
		
		[self.pageViewController setViewControllers:@[self.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
	}
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	UIViewController *viewControllerBefore = nil;
	NSUInteger index = [self.viewControllers indexOfObject:viewController];
	if (index != NSNotFound)
	{
		index--;
		if (index != NSUIntegerMax)
		{
			viewControllerBefore = self.viewControllers[index];
		}
	}
	return viewControllerBefore;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	UIViewController *viewControllerAfter = nil;
	NSUInteger index = [self.viewControllers indexOfObject:viewController];
	if (index != NSNotFound)
	{
		index++;
		if (index != [self.viewControllers count])
		{
			viewControllerAfter = self.viewControllers[index];
		}
	}
	return viewControllerAfter;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
	return (NSInteger)[self.viewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	if (self.viewControllers && [self.pageViewController.viewControllers count])
	{
		NSUInteger index = [self.viewControllers indexOfObject:self.pageViewController.viewControllers[0]];
		if (index != NSNotFound)
		{
			return index;
		}
	}
	return 0;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
	BOOL handled = NO;
	if (self.viewControllers && [self.pageViewController.viewControllers count])
	{
		NSUInteger index = [self.viewControllers indexOfObject:self.pageViewController.viewControllers[0]];
		if (index != NSNotFound)
		{
			UIPageViewControllerNavigationDirection navDirection;
			switch (direction) {
				case UIAccessibilityScrollDirectionLeft:
				case UIAccessibilityScrollDirectionNext:
					index++;
					if (index != [self.viewControllers count])
					{
						handled = YES;
					}
					navDirection = UIPageViewControllerNavigationDirectionForward;
					break;
				case UIAccessibilityScrollDirectionRight:
				case UIAccessibilityScrollDirectionPrevious:
					index--;
					if (index != NSUIntegerMax)
					{
						handled = YES;
					}
					navDirection = UIPageViewControllerNavigationDirectionReverse;
					break;
				default:
					break;
			}
			if (handled)
			{
				[self.pageViewController setViewControllers:@[self.viewControllers[index]] direction:navDirection animated:YES completion:^(BOOL finished) {
					UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil);
				}];
			}
		}
	}
	return handled;
}

@end
