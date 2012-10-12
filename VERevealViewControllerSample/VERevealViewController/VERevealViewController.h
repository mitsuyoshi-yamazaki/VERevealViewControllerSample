//
//  VERevealViewController.h
//  VERevealViewControllerSample
//
//  Created by Yamazaki Mitsuyoshi on 10/8/12.
//  Copyright (c) 2012 Mitsuyoshi Yamazaki. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kVERevealViewControllerRelationshipSegueIdentifierRootViewController;	//@"toRootViewContrllerSegue";
static NSString *const kVERevealViewControllerRelationshipSegueIdentifierLeftViewController;	//@"toLeftViewContrllerSegue";
static NSString *const kVERevealViewControllerRelationshipSegueIdentifierRightViewController;	//@"toRightViewContrllerSegue";

typedef enum {
	VERevealViewControllerStateHiddenSideViews,
	VERevealViewControllerStateRevealedLeftView,
	VERevealViewControllerStateRevealedRightView,
}VERevealViewControllerStates;

@interface VERevealViewController : UIViewController

@property (nonatomic, weak) UIViewController *leftViewController;
@property (nonatomic, weak) UIViewController *rightViewController;
@property (nonatomic, weak) UIViewController *rootViewController;

@property (nonatomic) CGFloat leftViewWidth;
@property (nonatomic) CGFloat rightViewWidth;
@property (nonatomic, readonly) VERevealViewControllerStates state;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)revealLeftViewControllerAnimated:(BOOL)animated;
- (void)revealRightViewControllerAnimated:(BOOL)animated;
- (void)hideSideViewControllerAnimated:(BOOL)animated;

@end
