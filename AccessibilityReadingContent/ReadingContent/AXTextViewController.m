//
//  AXTextViewController.m
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

#import "AXTextViewController.h"
#import "AXTextReadingContentView.h"

@interface AXTextViewController ()

@end

@implementation AXTextViewController

- (void)setIsLastPage:(bool)isLastPage
{
	_isLastPage = isLastPage;
	[self ax_configureCausesPageTurn];
}

- (void)setTextView:(AXTextView *)textView
{
	if (textView != _textView)
	{
		_textView = textView;
		[self ax_configureCausesPageTurn];
	}
}

- (void)ax_configureCausesPageTurn
{
	if ([self.textView respondsToSelector:@selector(setCausesPageTurn:)])
	{
		((AXTextReadingContentView *)self.textView).causesPageTurn = !self.isLastPage;
	}
}

@end
