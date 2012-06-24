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

@interface BPXLTextViewController ()
@property (nonatomic) BPXLTextView *textView;
@end

@implementation BPXLTextViewController

- (NSAttributedString *)loremIpsum
{
	NSString *loremIpsum = @"A screen reader is a software application that attempts to identify and interpret what is being displayed on the screen (or, more accurately, sent to standard output, whether a video monitor is present or not). This interpretation is then re-presented to the user with text-to-speech, sound icons, or a Braille output device. Screen readers are a form of assistive technology (AT) potentially useful to people who are blind, visually impaired, illiterate or learning disabled, often in combination with other AT, such as screen magnifiers.\nA person's choice of screen reader is dictated by many factors, including platform, cost (even to upgrade a screen reader can cost hundreds of U.S. dollars), and the role of organizations like charities, schools, and employers. Screen reader choice is contentious: differing priorities and strong preferences are common.[citation needed]\nMicrosoft Windows operating systems have included the Microsoft Narrator light-duty screen reader since Windows 2000. Apple Inc. Mac OS X includes VoiceOver, a feature-rich screen reader. The console-based Oralux Linux distribution ships with three screen-reading environments: Emacspeak, Yasr and Speakup. The open source GNOME desktop environment long included Gnopernicus and now includes Orca.\nThere are also open source screen readers, such as the Linux Screen Reader for GNOME and NonVisual Desktop Access for Windows.\nsource: http://en.wikipedia.org/wiki/Screen_reader";
	
	CTFontRef noteworthy24 = CTFontCreateWithName(CFSTR("Noteworthy"), 24, NULL);
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObject:(__bridge id)noteworthy24 forKey:(id)kCTFontAttributeName];
	CFRelease(noteworthy24);
	
	return [[NSAttributedString alloc] initWithString:loremIpsum attributes:normalAttributes];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Swap out the text view class to try out different behaviors
	self.textView = [[BPXLTextViewReadingContent alloc] initWithFrame:self.view.bounds];
	self.textView.attributedString = [self loremIpsum];
	[self.view addSubview:self.textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end
