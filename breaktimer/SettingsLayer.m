//
//  SettingsLayer.m
//  breaktimer
//
//  Created by Nathan Demick on 10/23/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "SettingsLayer.h"
#import "GameConfig.h"
#import "CCSlider.h"

@implementation SettingsLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if ((self = [super init])) 
	{
		CGSize windowSize = [CCDirector sharedDirector].winSize;
		NSString *hdSuffix = @"";
		int defaultFontSize = 18;
		int fontMultiplier = 1;

		// Add background
		CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
		bg.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:bg];
		
		// Used to determine if notifications need to be re-scheduled
		settingsHaveChanged = NO;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Default values
		workMinutes = [defaults integerForKey:@"workMinutes"];
		breakMinutes = [defaults integerForKey:@"breakMinutes"];
		
		// Create label that shows how long each work interval is
		workSliderLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Work Time (%i minutes)", workMinutes] fontName:@"museo.otf" fontSize:18];
		workSliderLabel.color = ccc3(33, 33, 33);
		workSliderLabel.position = ccp(windowSize.width / 2, windowSize.height - workSliderLabel.contentSize.height);
		[self addChild:workSliderLabel];
		
		// Create "work" slider
		CCSlider *workSlider = [CCSlider sliderWithBackgroundFile:[NSString stringWithFormat:@"slider-line%@.png", hdSuffix] thumbFile:[NSString stringWithFormat:@"slider-thumb%@.png", hdSuffix]];
		workSlider.tag = kWorkSliderTag;
		workSlider.delegate = self;
		workSlider.value = (float)(workMinutes - 30) / 150;	// Convert 30 - 180 down to a number between 0 and 1
		workSlider.position = ccp(windowSize.width / 2, workSliderLabel.position.y - workSlider.contentSize.height * 3);
		[self addChild:workSlider];
		
		// Create label that shows how long each work interval is
		breakSliderLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Break Time (%i minutes)", breakMinutes] fontName:@"museo.otf" fontSize:18];
		breakSliderLabel.color = ccc3(33, 33, 33);
		breakSliderLabel.position = ccp(windowSize.width / 2, workSlider.position.y - workSliderLabel.contentSize.height * 2);
		[self addChild:breakSliderLabel];
		
		// Create "break" slider
		CCSlider *breakSlider = [CCSlider sliderWithBackgroundFile:[NSString stringWithFormat:@"slider-line%@.png", hdSuffix] thumbFile:[NSString stringWithFormat:@"slider-thumb%@.png", hdSuffix]];
		breakSlider.tag = kBreakSliderTag;
		breakSlider.delegate = self;
		breakSlider.value = (float)(breakMinutes - 1) / 14;	// Convert 1 - 15 down to a number between 0 and 1
		breakSlider.position = ccp(windowSize.width / 2, breakSliderLabel.position.y - breakSlider.contentSize.height * 3);
		[self addChild:breakSlider];

		/* Create additional labels/buttons */
		
		// Show notifications
		// Repeat notifications
		// Device sleep
		
		int margin = 20;	// Margin from sides of screen for labels/buttons
		
		CCLabelTTF *showNotificationsLabel = [CCLabelTTF labelWithString:@"Display Notifications" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier * 1.5) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		showNotificationsLabel.color = ccc3(33, 33, 33);
		showNotificationsLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 + showNotificationsLabel.contentSize.height);
		[self addChild:showNotificationsLabel];

		CCLabelTTF *repeatNotificationsLabel = [CCLabelTTF labelWithString:@"Repeat Notifications" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier * 1.5) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		repeatNotificationsLabel.color = ccc3(33, 33, 33);
		repeatNotificationsLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:repeatNotificationsLabel];
		
		CCLabelTTF *deviceSleepLabel = [CCLabelTTF labelWithString:@"Device Sleep" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier * 1.5) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		deviceSleepLabel.color = ccc3(33, 33, 33);
		deviceSleepLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 - deviceSleepLabel.contentSize.height);
		[self addChild:deviceSleepLabel];
		
		CCMenuItemToggle *showNotificationsButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
			// Does anything happen here?
			NSLog(@"Selected button: %i", [(CCMenuItemToggle *)sender selectedIndex]);
		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
		
		CCMenuItemToggle *repeatNotificationsButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
			// Does anything happen here?
			NSLog(@"Selected button: %i", [(CCMenuItemToggle *)sender selectedIndex]);
		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
		
		CCMenuItemToggle *deviceSleepButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
			// Does anything happen here?
			NSLog(@"Selected button: %i", [(CCMenuItemToggle *)sender selectedIndex]);
		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
		
		
		CCMenu *buttonsMenu = [CCMenu menuWithItems:showNotificationsButton, repeatNotificationsButton, deviceSleepButton, nil];
		buttonsMenu.position = ccp(windowSize.width - showNotificationsButton.contentSize.width / 2 - margin, windowSize.height / 2);
		[buttonsMenu alignItemsVerticallyWithPadding:defaultFontSize * fontMultiplier * 1.5];
		[self addChild:buttonsMenu];
		
		// Create "save" button to transition back to 
		CCMenuItemImage *saveButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"save-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"save-button-selected%@.png", hdSuffix] block:^(id sender) {
			if (settingsHaveChanged)
			{
				// Cancel previously scheduled notifications
				[[UIApplication sharedApplication] cancelAllLocalNotifications];
				
				// Create all the notification objects before transitioning back to clock
				// Do work in new thread since it's actually pretty slow
				[NSThread detachNewThreadSelector:@selector(setUpNotifications) toTarget:self withObject:nil];
			}
			
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:1.0 scene:[HelloWorldLayer scene]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenu *menu = [CCMenu menuWithItems:saveButton, nil];
		menu.position = ccp(windowSize.width / 2, saveButton.contentSize.height);
		[self addChild:menu];
		
	}
	return self;
}

/**
 * Called when the scene is unloaded; sets up the local notifications based on user choices
 */
- (void)setUpNotifications
{
	// When notification scheduling is turned on
	// 1. Get the current date, but add X seconds to it, where X is the time interval between breaks
	// 2. Set the repeatInterval to be X + break time
	
	// Hmm, apparently you can't do custom time intervals
	// So, you'll have to make a loop and schedule 64 notifications, manually setting the time for each one
	// Whenever the app is launched, you'll have to clear all notifications and re-schedule, based on a saved (serialized) value
	
	NSLog(@"Work minutes: %i", workMinutes);
	NSLog(@"Break minutes: %i", breakMinutes);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Write some witty reminders
	NSArray *wittyComments = [NSArray arrayWithObjects:@"Take five.",
							  @"Get a glass of water.",
							  @"Go for a walk.",
							  @"Stretch your legs.",
							  @"Touch your toes.",
							  @"Do some jumping jacks.",
							  @"Get a cup of coffee.",
							  @"Do some deep breathing.",
							  @"Step outside.",
							  nil];
	
	// Do a loop that sets up max number of notifications
	for (int i = 1; i <= kMaxNotificationLimit; i++)
	{
		// Determine intervals between alerts
		// First alert is just the "work" interval
		// Subsequent alerts are work + break intervals
		int notificationIntervalInSeconds = i == 1 ? workMinutes * 60 : (workMinutes * 60 * i) + (breakMinutes * 60 * (i - 1));
		
		// Create date obj that will be used for our reminder
		NSDate *notificationTime = [NSDate dateWithTimeIntervalSinceNow:notificationIntervalInSeconds];
		
		// Create new notification obj
		UILocalNotification *notification = [[UILocalNotification alloc] init];
		notification.fireDate = notificationTime;
		notification.timeZone = [NSTimeZone defaultTimeZone];
		
		// Choose random "witty comment"
		int random = (float)(arc4random() % 100) / 100 * [wittyComments count];	// 0 -> array length
		notification.alertBody = [wittyComments objectAtIndex:random];
		
		// Also set as the userInfo property, so that the custom UIAlertView the app creates can use the same text
		notification.userInfo = [NSDictionary dictionaryWithObject:[wittyComments objectAtIndex:random] forKey:@"text"];
		
		notification.alertAction = @"Edit Reminders";
		notification.soundName = UILocalNotificationDefaultSoundName;
//		notification.applicationIconBadgeNumber = 1;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		[notification release];
	}
	
	[pool release];
}

/**
 * Receives messages from CCSliders being changed
 */
- (void)valueChanged:(float)value tag:(int)tag
{
	// range sentinel
	value = MIN(value, 1.0f);
	value = MAX(value, 0.0f);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// set value * 100
	switch (tag) 
	{
		case kWorkSliderTag:
			// 30 - 180 = (0 - 150) + 30
			workMinutes = (value * 150) + 30;
			workSliderLabel.string = [NSString stringWithFormat:@"Work Time (%i minutes)", workMinutes];
			[defaults setInteger:workMinutes forKey:@"workMinutes"];
			break;
		case kBreakSliderTag:
			// 1 - 15 = (0 - 14) + 1
			breakMinutes = (value * 14) + 1;
			breakSliderLabel.string = [NSString stringWithFormat:@"Break Time (%i minutes)", breakMinutes];
			[defaults setInteger:breakMinutes forKey:@"breakMinutes"];
			break;
		default:
			break;
	}
	
	[defaults synchronize];
	
	// Tell the app that we need to re-save our settings
	settingsHaveChanged = YES;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
