//
//  VERevealViewController.m
//  VERevealViewControllerSample
//
//  Created by Yamazaki Mitsuyoshi on 10/8/12.
//  Copyright (c) 2012 Mitsuyoshi Yamazaki. All rights reserved.
//

#import "VERevealViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kVERevealViewControllerRelationshipSegueIdentifierRootViewController = @"toRootViewContrllerSegue";
static NSString *const kVERevealViewControllerRelationshipSegueIdentifierLeftViewController = @"toLeftViewContrllerSegue";
static NSString *const kVERevealViewControllerRelationshipSegueIdentifierRightViewController = @"toRightViewContrllerSegue";

static NSTimeInterval const _kVERevealViewControllerAnimationDulation = 0.3f;
static CGFloat const _kVERevealViewControllerSideViewDefaultWidth = 240.0f;

@interface VERevealViewController () {
	UIView *_topView;	// a view that the rootView on. to not add gestureRecognizers to rootView.
	UIView *_sideViewBackgroundView;	// a view that hides the back most side view.
	BOOL _isPanning;
}

- (void)initializeRevealViewController;
- (void)initializeRootViewController:(UIViewController *)controller frame:(CGRect)frame;
- (void)initializeChildViewController:(UIViewController *)controller frame:(CGRect)frame;
- (void)initializeChildViewControllersFromSegue;
- (void)initializeRootViewShadow;
- (void)animateRootViewToFrame:(CGRect)frame;
- (CGRect)subViewFrame;
- (CGRect)leftViewFrame;
- (CGRect)rightViewFrame;
- (void)rootViewDidTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)rootViewDidPan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)panGestureDidEndAnimation;
- (void)setTopViewFrame:(CGRect)frame;
- (BOOL)isLeftViewVisible;
- (BOOL)isRightViewVisible;

@end

@implementation VERevealViewController

@synthesize rootViewController = _rootViewController;
@synthesize leftViewController = _leftViewController;
@synthesize rightViewController = _rightViewController;
@synthesize leftViewWidth = _leftViewWidth;
@synthesize rightViewWidth = _rightViewWidth;
@synthesize state = _state;

#pragma mark - Lifecycle
- (id)initWithRootViewController:(UIViewController *)rootViewController {
	
	if (rootViewController == nil) {
		[NSException raise:@"ほげ" format:@"rootViewControllerは必須だよ"];
	}
	
	self = [super init];
	if (self) {
		[self initializeRevealViewController];
		
		_rootViewController = rootViewController;
		[self addChildViewController:self.rootViewController];
		[self.rootViewController didMoveToParentViewController:self];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initializeRevealViewController];
	}
	return self;
}

- (void)initializeRevealViewController  {
	_leftViewWidth = _kVERevealViewControllerSideViewDefaultWidth;
	_rightViewWidth = _kVERevealViewControllerSideViewDefaultWidth;
	_state = VERevealViewControllerStateHiddenSideViews;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// frameの調達先がわかったらloadViewでやる
	_sideViewBackgroundView = [[UIView alloc] initWithFrame:self.subViewFrame];
	_sideViewBackgroundView.userInteractionEnabled = NO;
	[self.view addSubview:_sideViewBackgroundView];
	
	_topView = [[UIView alloc] initWithFrame:self.subViewFrame];
	_topView.userInteractionEnabled = YES;
	[self.view addSubview:_topView];
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rootViewDidPan:)];
	[_topView addGestureRecognizer:panGestureRecognizer];
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rootViewDidTap:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	[_topView addGestureRecognizer:tapGestureRecognizer];
	
	if (self.rootViewController == nil) {
		[self initializeChildViewControllersFromSegue];
	}
	else {
		[_topView addSubview:self.rootViewController.view];
		[self.rootViewController.view setFrame:self.subViewFrame];
	}
	
	[self.view bringSubviewToFront:_topView];
	[self initializeRootViewShadow];
	
	_isPanning = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Initialize ChildViewControllers From Segue
- (void)initializeChildViewControllersFromSegue {
	// 存在しないidentifierのsegue呼んでも問題ないかチェック
	
	[self performSegueWithIdentifier:kVERevealViewControllerRelationshipSegueIdentifierLeftViewController sender:self];
	[self performSegueWithIdentifier:kVERevealViewControllerRelationshipSegueIdentifierRightViewController sender:self];
	[self performSegueWithIdentifier:kVERevealViewControllerRelationshipSegueIdentifierRootViewController sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// カスタムセグエ作るときは、addChildViewControllerとかはセグエのperformメソッドの中でやるのか？
	// そう。
	
	if ([segue.identifier isEqualToString:kVERevealViewControllerRelationshipSegueIdentifierRootViewController]) {
		_rootViewController = segue.destinationViewController;
		[self initializeRootViewController:self.rootViewController frame:self.subViewFrame];
	}
	else if ([segue.identifier isEqualToString:kVERevealViewControllerRelationshipSegueIdentifierLeftViewController]) {
		self.leftViewController = segue.destinationViewController;
	}
	else if ([segue.identifier isEqualToString:kVERevealViewControllerRelationshipSegueIdentifierRightViewController]) {
		self.rightViewController = segue.destinationViewController;
	}	
}

#pragma mark - ContainerViewController
#pragma mark For iOS6
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
	return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
	return YES;
}

#pragma mark For iOS5
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
	return YES;
}

#pragma mark - Accessor
- (void)setLeftViewWidth:(CGFloat)leftViewWidth {

	// TODO 開いてたらアニメーション
	// ビューのサイズの変更
	_leftViewWidth = leftViewWidth;
}

- (void)setRightViewWidth:(CGFloat)rightViewWidth {
	_rightViewWidth = rightViewWidth;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
	// this method supporsed to be called when a side view is visible

	if (rootViewController == nil) {
		// rootViewController couldn't be nil
		return;
	}
	
	CGRect rootViewFrame = _topView.frame;
	BOOL isLeft = (rootViewFrame.origin.x > 0.0f);
	rootViewFrame.origin.x = isLeft ? self.view.frame.size.width : -self.view.frame.size.width;
	CGSize shadowOffset = CGSizeMake(10.0f, 0.0f);
	shadowOffset.width *= isLeft ? 1.0f : -1.0f;
	
	[UIView animateWithDuration:0.2f animations:^(void) {
//		[self setTopViewFrame:rootViewFrame];	// ここでは使わない
		[_topView setFrame:rootViewFrame];
	} completion:^(BOOL finished) {
		
		[_rootViewController removeFromParentViewController];
		
		_rootViewController = rootViewController;
		[self initializeRootViewController:self.rootViewController frame:self.subViewFrame];
		[self initializeRootViewShadow];
		_topView.layer.shadowOffset = shadowOffset;
		
		[self hideSideViewControllerAnimated:YES];
	}];
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
	
	BOOL wasLeftViewVisible = NO;
	
	if (self.isLeftViewVisible) {
		wasLeftViewVisible = YES;
		[self hideSideViewControllerAnimated:YES];
	}
	
	[_leftViewController removeFromParentViewController];	// viewはremoveFromSuperviewされるのか？
	
	_leftViewController = leftViewController;
	[self initializeChildViewController:self.leftViewController frame:self.leftViewFrame];
	
	if (wasLeftViewVisible && self.leftViewController) {
		[self revealLeftViewControllerAnimated:YES];
	}
}

- (void)setRightViewController:(UIViewController *)rightViewController {
	
	BOOL wasRightViewVisible = NO;
	
	if (self.isRightViewVisible) {
		wasRightViewVisible = YES;
		[self hideSideViewControllerAnimated:YES];
	}
	
	[_rightViewController removeFromParentViewController];
	
	_rightViewController = rightViewController;
	[self initializeChildViewController:self.rightViewController frame:self.rightViewFrame];
	
	if (wasRightViewVisible && self.rightViewController) {
		[self revealRightViewControllerAnimated:YES];
	}
}


#pragma mark - ChildViewController Initialization
- (void)initializeRootViewController:(UIViewController *)controller frame:(CGRect)frame {
	
	[self addChildViewController:controller];
	[controller.view setFrame:frame];
	[_topView addSubview:controller.view];
	[controller didMoveToParentViewController:self];
}

- (void)initializeChildViewController:(UIViewController *)controller frame:(CGRect)frame {
	
	[self addChildViewController:controller];
	[controller.view setFrame:frame];
	[self.view addSubview:controller.view];
	[controller didMoveToParentViewController:self];
}

- (void)initializeRootViewShadow {
	
	_topView.layer.shadowColor = [UIColor blackColor].CGColor;
	_topView.layer.shadowRadius = 6.0f;
	_topView.layer.shadowOpacity = 0.3f;
	_topView.layer.shadowOffset = CGSizeMake(10.0f, 0.0f);
}

#pragma mark - SideViewController Animation
- (void)revealLeftViewControllerAnimated:(BOOL)animated {
	
	if (self.leftViewController == nil) {
		return;
	}
			
	CGRect rootViewFrame = self.subViewFrame;
	rootViewFrame.origin.x += self.leftViewWidth;
	
	[self animateRootViewToFrame:rootViewFrame];
	
	_state = VERevealViewControllerStateRevealedLeftView;
}

- (void)revealRightViewControllerAnimated:(BOOL)animated {
	
	if (self.rightViewController == nil) {
		return;
	}
		
	CGRect rootViewFrame = self.subViewFrame;
	rootViewFrame.origin.x -= self.rightViewWidth;
	
	[self animateRootViewToFrame:rootViewFrame];
	
	_state = VERevealViewControllerStateRevealedRightView;
}

- (void)hideSideViewControllerAnimated:(BOOL)animated {
	
	[self animateRootViewToFrame:self.subViewFrame];
	
	_state = VERevealViewControllerStateHiddenSideViews;
}

- (void)animateRootViewToFrame:(CGRect)frame {
		
	[UIView animateWithDuration:_kVERevealViewControllerAnimationDulation animations:^(void) {
		[self setTopViewFrame:frame];
	}];
}

#pragma mark - SideView GestureRecognizer
- (void)rootViewDidTap:(UITapGestureRecognizer *)tapGestureRecognizer {
	
	NSLog(@"tapped : %@", tapGestureRecognizer);
	
	if (self.state != VERevealViewControllerStateHiddenSideViews) {
		[self hideSideViewControllerAnimated:YES];
	}
}

- (void)rootViewDidPan:(UIPanGestureRecognizer *)panGestureRecognizer {
	
	NSLog(@"panned : %@", panGestureRecognizer);
	
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			_isPanning = YES;
			break;
			
		case UIGestureRecognizerStateChanged: {
			
			CGRect topViewFrame = self.subViewFrame;
			topViewFrame.origin.x = [panGestureRecognizer translationInView:_topView].x;
			
			topViewFrame.origin.x += (self.state == VERevealViewControllerStateRevealedLeftView) ? self.leftViewWidth : 0.0f;
			topViewFrame.origin.x -= (self.state == VERevealViewControllerStateRevealedRightView) ? self.rightViewWidth : 0.0f;
			
			[self setTopViewFrame:topViewFrame];
			NSLog(@"topview frame ; %@", [NSValue valueWithCGRect:_topView.frame]);
			break;
		}
			
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
		default:
			_isPanning = NO;
			[self panGestureDidEndAnimation];
			break;
	}	
}

- (void)panGestureDidEndAnimation {
	
	CGFloat leftThresholdPoint = self.leftViewWidth * 0.4f;
	CGFloat rightThresholdPoint = self.rightViewWidth * -0.4f;
	CGFloat x = _topView.frame.origin.x;
	
	if (x > leftThresholdPoint) {
		[self revealLeftViewControllerAnimated:YES];
	}
	else if (x < rightThresholdPoint) {
		[self revealRightViewControllerAnimated:YES];
	}
	else {
		[self hideSideViewControllerAnimated:YES];
	}
}

#pragma mark - TopView Frame
- (void)setTopViewFrame:(CGRect)frame {
	
	CGRect nextFrame = frame;
	CGFloat x = frame.origin.x;
	
	if (x > 0.0f) {
		[self.view sendSubviewToBack:_sideViewBackgroundView];
		[self.view sendSubviewToBack:self.rightViewController.view];
		_sideViewBackgroundView.backgroundColor = self.leftViewController.view.backgroundColor;
		_topView.layer.shadowOffset = CGSizeMake(-10.0f, 0.0f);
		
		if (x > self.leftViewWidth) {
			nextFrame.origin.x = self.leftViewWidth;
		}
	}
	else if (x < 0.0f) {
		[self.view sendSubviewToBack:_sideViewBackgroundView];
		[self.view sendSubviewToBack:self.leftViewController.view];
		_sideViewBackgroundView.backgroundColor = self.rightViewController.view.backgroundColor;
		_topView.layer.shadowOffset = CGSizeMake(10.0f, 0.0f);
		
		if (x < -self.rightViewWidth) {
			nextFrame.origin.x = - self.rightViewWidth;
		}
	}
	
	[_topView setFrame:nextFrame];
}

#pragma mark - View Status
- (BOOL)isLeftViewVisible {
	
	if (_topView.frame.origin.x > 0.0f) {
		return YES;
	}
	return NO;
}

- (BOOL)isRightViewVisible {
	
	if (_topView.frame.origin.x < 0.0f) {
		return YES;
	}
	return NO;
}

- (CGRect)subViewFrame {
	return self.view.bounds;
}

- (CGRect)leftViewFrame {
	
	CGRect leftViewFrame = self.view.bounds;
	leftViewFrame.size.width = self.leftViewWidth;
	return leftViewFrame;
}

- (CGRect)rightViewFrame {
	
	CGRect rightViewFrame = self.view.bounds;
	rightViewFrame.origin.x = self.view.frame.size.width - self.rightViewWidth;
	rightViewFrame.size.width = self.rightViewWidth;
	return rightViewFrame;
}

@end
