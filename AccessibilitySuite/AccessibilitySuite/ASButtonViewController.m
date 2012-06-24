//
//  ASButtonViewController.m
//  AccessibilitySuite
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

#import "ASButtonViewController.h"

@interface ASButtonViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)pageChanged:(UIPageControl *)sender;
@property (weak, nonatomic) IBOutlet UIView *roundedRectButtonView;
@property (weak, nonatomic) IBOutlet UIView *backgroundImageButtonView;
@property (weak, nonatomic) IBOutlet UIView *bakedInTextImageButtonView;
@property (weak, nonatomic) IBOutlet UIView *accessibleImageButtonView;
@end

@implementation ASButtonViewController

#pragma mark - Init/Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Buttons";
	}
	return self;
}

- (void)dealloc
{
	_scrollView.delegate = nil;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 4, self.scrollView.bounds.size.height);
	
	CGRect panelRect = self.scrollView.bounds;
	self.roundedRectButtonView.frame = panelRect;
	[self.scrollView addSubview:self.roundedRectButtonView];
	panelRect.origin.x += panelRect.size.width;
	self.backgroundImageButtonView.frame = panelRect;
	[self.scrollView addSubview:self.backgroundImageButtonView];
	panelRect.origin.x += panelRect.size.width;
	self.bakedInTextImageButtonView.frame = panelRect;
	[self.scrollView addSubview:self.bakedInTextImageButtonView];
	panelRect.origin.x += panelRect.size.width;
	self.accessibleImageButtonView.frame = panelRect;
	[self.scrollView addSubview:self.accessibleImageButtonView];
}

#pragma mark - Page Control

- (IBAction)pageChanged:(UIPageControl *)sender
{
	self.scrollView.contentOffset = CGPointMake(sender.currentPage * self.scrollView.bounds.size.width, 0.0f);
}

#pragma mark - Scroll

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.pageControl.currentPage = trunc(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

@end
