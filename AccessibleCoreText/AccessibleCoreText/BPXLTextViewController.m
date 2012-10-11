//
//  BPXLTextViewController.m
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

#import "BPXLTextViewController.h"
#import "BPXLTextView.h"
#import "BPXLTextViewContainer.h"
#import "BPXLTextViewReadingContent.h"

#define READINGCONTENT 1

@interface BPXLTextViewController ()
@property (nonatomic) BPXLTextView *textView;
@end

@implementation BPXLTextViewController

#pragma mark - View Controller Life Cycle

+ (instancetype)newWithText:(NSAttributedString *)text
{
	BPXLTextViewController *controller = [BPXLTextViewController new];
	controller.text = text;
	return controller;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Swap out the text view class to try out different behaviors
#if READINGCONTENT
	self.textView = [[BPXLTextViewReadingContent alloc] initWithFrame:self.view.bounds];
	((BPXLTextViewReadingContent *)self.textView).causesPageTurn = !self.isLastPage;
#else
	self.textView = [[BPXLTextViewContainer alloc] initWithFrame:self.view.bounds];
#endif
	self.textView.attributedString = self.text;
	[self.view addSubview:self.textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)setIsLastPage:(bool)isLastPage
{
	_isLastPage = isLastPage;
#if READINGCONTENT
	if (self.textView)
		((BPXLTextViewReadingContent *)self.textView).causesPageTurn = !self.isLastPage;
#endif
}

#pragma mark - Text

- (void)setText:(NSAttributedString *)text
{
	if (text != _text)
	{
		_text = text;
		if (self.textView)
			[self.textView setAttributedString:text];
	}
}

@end
