//
//  UIViewController+VERevealViewController.m
//  VERevealViewControllerSample
//
//  Created by Yamazaki Mitsuyoshi on 10/9/12.
//  Copyright (c) 2012 Mitsuyoshi Yamazaki. All rights reserved.
//

#import "UIViewController+VERevealViewController.h"

@implementation UIViewController (VERevealViewController)

@dynamic revealViewController;

- (VERevealViewController *)revealViewController {
	
	if ([self.parentViewController isKindOfClass:[VERevealViewController class]]) {
		NSLog(@"%@'s parentViewController is revealViewController %@", self, self.parentViewController);
		return (VERevealViewController *)self.parentViewController;
	}
	NSLog(@"%@'s parentViewController is NOT revealViewController %@", self, self.parentViewController);
	return nil;
}

@end
