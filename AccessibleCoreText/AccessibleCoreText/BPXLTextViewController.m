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

@interface BPXLTextViewController ()
@property (strong, nonatomic) BPXLTextView *textView;
@end

@implementation BPXLTextViewController
@synthesize textView=_textView;

- (NSAttributedString *)loremIpsum
{
	NSString *loremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit.\n\n";
	
	NSString *hugeString = loremIpsum;
	if (YES) hugeString = [hugeString stringByAppendingString:loremIpsum];
	if (YES) hugeString = [hugeString stringByAppendingString:loremIpsum];
	
	CTFontRef noteworthy24 = CTFontCreateWithName(CFSTR("Noteworthy"), 24, NULL);
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObject:(__bridge id)noteworthy24 forKey:(id)kCTFontAttributeName];
	CFRelease(noteworthy24);
	
	return [[NSAttributedString alloc] initWithString:hugeString attributes:normalAttributes];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.textView = [[BPXLTextView alloc] initWithFrame:self.view.bounds];
	self.textView.attributedString = [self loremIpsum];
	[self.view addSubview:self.textView];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.textView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end
