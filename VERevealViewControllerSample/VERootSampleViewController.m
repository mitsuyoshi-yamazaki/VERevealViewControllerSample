//
//  VERootSampleViewController.m
//  VERevealViewControllerSample
//
//  Created by Yamazaki Mitsuyoshi on 10/9/12.
//  Copyright (c) 2012 Mitsuyoshi Yamazaki. All rights reserved.
//

#import "VERootSampleViewController.h"

#import "UIViewController+VERevealViewController.h"

@interface VERootSampleViewController ()

@end

@implementation VERootSampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealLeft:(id)sender {
	[self.navigationController.revealViewController revealLeftViewControllerAnimated:YES];
}

- (IBAction)revealRight:(id)sender {
	[self.navigationController.revealViewController revealRightViewControllerAnimated:YES];
}

@end
