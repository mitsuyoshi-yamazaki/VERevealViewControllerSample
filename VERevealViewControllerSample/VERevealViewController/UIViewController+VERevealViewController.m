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
		return (VERevealViewController *)self.parentViewController;
	}
	return nil;
}

@end
