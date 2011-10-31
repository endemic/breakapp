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
		int defaultFontSize = 22;
		int fontMultiplier = 1;

		// Add background
		CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
		bg.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:bg];
		
		// Used to determine if notifications need to be re-scheduled
		settingsHaveChanged = NO;
		
		// Write some witty reminders
		wittyComments = [[NSArray arrayWithObjects:@"Take five.",
								  @"Get a glass of water.",
								  @"Go for a walk.",
								  @"Stretch your legs.",
								  @"Touch your toes.",
								  @"Do some jumping jacks.",
								  @"Get a cup of coffee.",
								  @"Do some deep breathing.",
								  @"Step outside.",
								  nil] retain];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Default values
		workMinutes = [defaults integerForKey:@"workMinutes"];
		breakMinutes = [defaults integerForKey:@"breakMinutes"];
		
		// Create label that shows how long each work interval is
		workSliderLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Work Time (%i minutes)", workMinutes] fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		workSliderLabel.color = ccc3(255, 255, 255);
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
		breakSliderLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Break Time (%i minutes)", breakMinutes] fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		breakSliderLabel.color = ccc3(255, 255, 255);
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
		
		int margin = 20;	// Margin from sides of screen for labels/buttons
		
		CCLabelTTF *showNotificationsLabel = [CCLabelTTF labelWithString:@"Display Notifications" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier * 1.5) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		showNotificationsLabel.color = ccc3(255, 255, 255);
		showNotificationsLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:showNotificationsLabel];

//		CCLabelTTF *repeatNotificationsLabel = [CCLabelTTF labelWithString:@"Repeat Notifications" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
//		repeatNotificationsLabel.color = ccc3(255, 255, 255);
//		repeatNotificationsLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
//		[self addChild:repeatNotificationsLabel];
		
		CCLabelTTF *deviceSleepLabel = [CCLabelTTF labelWithString:@"Device Sleep" dimensions:CGSizeMake(windowSize.width - margin * 2, defaultFontSize * fontMultiplier * 1.5) alignment:CCTextAlignmentLeft fontName:@"museo.otf" fontSize:defaultFontSize * fontMultiplier];
		deviceSleepLabel.color = ccc3(255, 255, 255);
		deviceSleepLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 - showNotificationsLabel.contentSize.height * 2);
		[self addChild:deviceSleepLabel];
		
		// SHOW NOTIFICATIONS
		CCMenuItemToggle *showNotificationsButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
			switch ([(CCMenuItemToggle *)sender selectedIndex]) 
			{
				case 0:
					[defaults setBool:YES forKey:@"notifications"];
					NSLog(@"On!");
					break;
				case 1:
					[defaults setBool:NO forKey:@"notifications"];
					NSLog(@"Off!");
					break;
				default:
					break;
			}
			
			[defaults synchronize];
			
		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
		
		// Set the default state of the button if preference == "off"
		if (![defaults boolForKey:@"notifications"]) 
		{
			[showNotificationsButton setSelectedIndex:1];
		}
		
//		// REPEAT NOTIFICATIONS
//		CCMenuItemToggle *repeatNotificationsButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
//			switch ([(CCMenuItemToggle *)sender selectedIndex]) 
//			{
//				case 0:
//					[defaults setBool:YES forKey:@"repeatNotifications"];
//					NSLog(@"On!");
//					break;
//				case 1:
//					[defaults setBool:NO forKey:@"repeatNotifications"];
//					NSLog(@"Off!");
//					break;
//				default:
//					break;
//			}
//			
//			[defaults synchronize];
//			
//		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
//		
//		// Set the default state of the button if preference == "off"
//		if (![defaults boolForKey:@"repeatNotifications"]) 
//		{
//			[repeatNotificationsButton setSelectedIndex:1];
//		}
		
		// SLEEP BUTTON
		CCMenuItemToggle *deviceSleepButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
			switch ([(CCMenuItemToggle *)sender selectedIndex]) 
			{
				case 0:
					NSLog(@"Sleep on");
					[defaults setBool:YES forKey:@"sleep"];
					[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
					break;
				case 1:
					[defaults setBool:NO forKey:@"sleep"];
					[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
					NSLog(@"Sleep off");
					break;
				default:
					break;
			}
			
			[defaults synchronize];
			
		} items:[CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"on-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"on-button-selected%@.png", hdSuffix]], [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"off-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"off-button-selected%@.png", hdSuffix]], nil];
		
		// Set the default state of the button if preference == "off"
		if (![defaults boolForKey:@"sleep"]) 
		{
			[deviceSleepButton setSelectedIndex:1];
		}
		
		CCMenu *buttonsMenu = [CCMenu menuWithItems:showNotificationsButton, deviceSleepButton, nil];
		buttonsMenu.position = ccp(windowSize.width - showNotificationsButton.contentSize.width / 2 - margin, windowSize.height / 2 - showNotificationsLabel.contentSize.height);
		[buttonsMenu alignItemsVerticallyWithPadding:defaultFontSize * fontMultiplier * 1.5];
		[self addChild:buttonsMenu];
		
		// Create "save" button to transition back to 
		CCMenuItemImage *saveButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"save-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"save-button-selected%@.png", hdSuffix] block:^(id sender) {
			
			if (settingsHaveChanged && [defaults boolForKey:@"notifications"])
			{
				// Cancel previously scheduled notifications
				[[UIApplication sharedApplication] cancelAllLocalNotifications];

				// Schedule initial notification
				[self setUpNotification];
				
				// Spawn thread to create the rest
				[NSThread detachNewThreadSelector:@selector(setUpRepeatNotifications) toTarget:self withObject:nil];
			}

			
			// Cancel recurring notifications if user desires
			if (![defaults boolForKey:@"notifications"])
			{
				[[UIApplication sharedApplication] cancelAllLocalNotifications];
			}
			
			// Transition back to clock
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
 * Called when the scene is unloaded; sets up the first recurring notification
 */
- (void)setUpNotification
{
	NSLog(@"Creating one notification");

	// Determine intervals between alerts
	// First alert is just the "work" interval
	// Subsequent alerts are work + break intervals
	int notificationIntervalInSeconds = workMinutes * 60;
	
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
	
	notification.alertAction = @"Turn Off";
	notification.soundName = UILocalNotificationDefaultSoundName;
//	notification.applicationIconBadgeNumber = 1;
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	[notification release];
}

/**
 * Called when the scene is unloaded; sets up the local notifications based on user choices
 */
- (void)setUpRepeatNotifications
{
	// When notification scheduling is turned on
	// 1. Get the current date, but add X seconds to it, where X is the time interval between breaks
	// 2. Set the repeatInterval to be X + break time
	
	// Hmm, apparently you can't do custom time intervals
	// So, you'll have to make a loop and schedule 64 notifications, manually setting the time for each one
	// Whenever the app is launched, you'll have to clear all notifications and re-schedule, based on a saved (serialized) value
	
//	NSLog(@"Creating repeat notifications");
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Do a loop that sets up max number of notifications 2 - 64 (starting at 1)
	for (int i = 2; i <= kMaxNotificationLimit; i++)
	{
		// Determine intervals between alerts
		// First alert is just the "work" interval
		// Subsequent alerts are work + break intervals
		int notificationIntervalInSeconds = (workMinutes * 60 * i) + (breakMinutes * 60 * (i - 1));
		
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
			
			// Snap "work" minutes values to multiples of 5
			workMinutes = (workMinutes / 5) * 5;
			
			workSliderLabel.string = [NSString stringWithFormat:@"Work Time (%i minutes)", workMinutes];
			[defaults setInteger:workMinutes forKey:@"workMinutes"];
			break;
		case kBreakSliderTag:
			// 1 - 15 = (0 - 14) + 1
			breakMinutes = (value * 14) + 1;
			if (breakMinutes == 1)
			{
				breakSliderLabel.string = [NSString stringWithFormat:@"Break Time (%i minute)", breakMinutes];
			}
			else
			{
				breakSliderLabel.string = [NSString stringWithFormat:@"Break Time (%i minutes)", breakMinutes];
			}
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
	[wittyComments release];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
