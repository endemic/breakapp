//
//  AppDelegate.m
//  breaktimer
//
//  Created by Nathan Demick on 10/21/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
	{
		CCLOG(@"Retina Display Not supported");
	}
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Get user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Register some defaults
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:60], @"workMinutes", 
								[NSNumber numberWithInt:5], @"breakMinutes",
								[NSNumber numberWithBool:YES], @"sleep",
								[NSNumber numberWithBool:YES], @"notifications",
								[NSNumber numberWithBool:YES], @"repeatNotifications",
								nil]];
	
	// Turn "idle timer" off if user desires it
	if ([[defaults objectForKey:@"sleep"] boolValue] == NO)
	{
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
	
	// Handle notifications/badges
	application.applicationIconBadgeNumber = 0;
	
	UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (notification)
	{
//		NSLog(@"Received notification %@", notification);
	}
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[HelloWorldLayer scene]];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
//	NSLog(@"applicationWillResignActive");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
//	NSLog(@"applicationDidBecomeActive");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
//	NSLog(@"applicationDidEnterBackground");
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
//	NSLog(@"applicationDidEnterForeground");
	id layer = [[[CCDirector sharedDirector] runningScene] getChildByTag:kClockLayer];
	
	// If clock scene is running, update the position of the clock hands
	if (layer != nil && [layer isKindOfClass:[HelloWorldLayer class]])
	{
//		NSLog(@"calling [HelloWorldLayer seClockHands]");
		[(HelloWorldLayer *)layer updateClockHands];
		[(HelloWorldLayer *)layer updateBreakHands];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
//	NSLog(@"applicationSignificantTimeChange");
}

/*
 * Handle local notifications when app is running
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{	
	// Handle notifications/badges
	application.applicationIconBadgeNumber = 0;
	
	// Get the custom text associated w/ the notification
	NSDictionary *userInfo = notification.userInfo;
	
	// Create an alert
	UIAlertView *alertView;
	
	// Gets the single layer on the currently running scene
	id layer = [[[CCDirector sharedDirector] runningScene] getChildByTag:kClockLayer];
	
	// If clock scene is running, set UIAlertView delegate to that
	if (layer != nil && [layer isKindOfClass:[HelloWorldLayer class]])
	{
		alertView = [[[UIAlertView alloc] initWithTitle:@"BreakApp"
												message:[userInfo objectForKey:@"text"]
											   delegate:layer
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil] autorelease];
	}
	// Otherwise, just set it to the app delegate and ignore
	else
	{
		alertView = [[[UIAlertView alloc] initWithTitle:@"BreakApp"
												message:[userInfo objectForKey:@"text"]
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil] autorelease];
	}

	// Show the alert
	[alertView show];
}

/**
 * Handle clicking of the alert view
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Do nothing
	// Probably should re-update notifications here
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
