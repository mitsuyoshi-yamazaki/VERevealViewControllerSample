//
//  VESwapRootSegue.m
//  VERevealViewControllerSample
//
//  Created by Yamazaki Mitsuyoshi on 10/9/12.
//  Copyright (c) 2012 Mitsuyoshi Yamazaki. All rights reserved.
//

#import "VESwapRootSegue.h"

#import "UIViewController+VERevealViewController.h"

@implementation VESwapRootSegue

- (void)perform {
	
	VERevealViewController *revealViewController = [self.sourceViewController revealViewController];
	
	if (revealViewController == nil) {
		return;
	}
	
	[revealViewController setRootViewController:self.destinationViewController];
}

@end
