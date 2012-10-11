//
//  BPXLRootViewController.m
//  AccessibleCoreText
//
//  Created by Doug Russell on 10/10/12.
//
//

#import "BPXLRootViewController.h"
#import "BPXLTextViewController.h"

@interface BPXLRootViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSArray *viewControllers;
@end

@implementation BPXLRootViewController

#pragma mark - Page Content

- (NSAttributedString *)one
{
	NSString *loremIpsum = @"A screen reader is a software application that attempts to identify and interpret what is being displayed on the screen (or, more accurately, sent to standard output, whether a video monitor is present or not). This interpretation is then re-presented to the user with text-to-speech, sound icons, or a Braille output device. Screen readers are a form of assistive technology (AT) potentially useful to people who are blind, visually impaired, illiterate or learning disabled, often in combination with other AT, such as screen magnifiers.\nA person's choice of screen reader is dictated by many factors, including platform, cost (even to upgrade a screen reader can cost hundreds of U.S. dollars), and the role of organizations like charities, schools, and employers.";
	
	CTFontRef helv24 = CTFontCreateWithName(CFSTR("Helvetica"), 24, NULL);
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObject:(__bridge id)helv24 forKey:(id)kCTFontAttributeName];
	CFRelease(helv24);
	
	return [[NSAttributedString alloc] initWithString:loremIpsum attributes:normalAttributes];
}

- (NSAttributedString *)two
{
	NSString *loremIpsum = @"Screen reader choice is contentious: differing priorities and strong preferences are common.[citation needed]\nMicrosoft Windows operating systems have included the Microsoft Narrator light-duty screen reader since Windows 2000. Apple Inc. Mac OS X includes VoiceOver, a feature-rich screen reader. The console-based Oralux Linux distribution ships with three screen-reading environments: Emacspeak, Yasr and Speakup. The open source GNOME desktop environment long included Gnopernicus and now includes Orca.";
	
	CTFontRef helv24 = CTFontCreateWithName(CFSTR("Helvetica"), 24, NULL);
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObject:(__bridge id)helv24 forKey:(id)kCTFontAttributeName];
	CFRelease(helv24);
	
	return [[NSAttributedString alloc] initWithString:loremIpsum attributes:normalAttributes];
}

- (NSAttributedString *)three
{
	NSString *loremIpsum = @"There are also open source screen readers, such as the Linux Screen Reader for GNOME and NonVisual Desktop Access for Windows.";
	
	CTFontRef helv24 = CTFontCreateWithName(CFSTR("Helvetica"), 24, NULL);
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObject:(__bridge id)helv24 forKey:(id)kCTFontAttributeName];
	CFRelease(helv24);
	
	return [[NSAttributedString alloc] initWithString:loremIpsum attributes:normalAttributes];
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Store our view controller pages
	self.viewControllers = @[[BPXLTextViewController newWithText:[self one]], [BPXLTextViewController newWithText:[self two]], [BPXLTextViewController newWithText:[self three]]];
	[self.viewControllers[2] setIsLastPage:YES];
	// Setup page view controller
	self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	self.pageViewController.dataSource = self;
	self.pageViewController.delegate = self;
	[self.pageViewController setViewControllers:@[self.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
	[self.pageViewController willMoveToParentViewController:self];
	[self.view addSubview:self.pageViewController.view];
	[self.pageViewController didMoveToParentViewController:self];
	// Set a background color so we can see the page control
	self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	self.pageViewController.view.frame = self.view.bounds;
}

- (void)dealloc
{
	_pageViewController.dataSource = nil;
	_pageViewController.delegate = nil;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	NSUInteger index = [self.viewControllers indexOfObject:viewController];
	if (index != NSNotFound)
	{
		index--;
		if (index != NSUIntegerMax)
			return [self.viewControllers objectAtIndex:index];
	}
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	NSUInteger index = [self.viewControllers indexOfObject:viewController];
	if (index != NSNotFound)
	{
		index++;
		if (index != [self.viewControllers count])
			return [self.viewControllers objectAtIndex:index];
	}
	return nil;
}

// Present a page control in iOS 6

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

// Handling accessibility scroll in the view controller only works in iOS 6, you'll have to forward these manually from the view or handle them inside the view in iOS 5

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
						handled = YES;
					navDirection = UIPageViewControllerNavigationDirectionForward;
					break;
				case UIAccessibilityScrollDirectionRight:
				case UIAccessibilityScrollDirectionPrevious:
					index--;
					if (index != NSUIntegerMax)
						handled = YES;
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
