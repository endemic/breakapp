//
//  SettingsLayer.m
//  breaktimer
//
//  Created by Nathan Demick on 10/23/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "SettingsLayer.h"
#import "GameConfig.h"

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
		
//		NSString *hdSuffix = @"";

		// These will be user-selectable, eventually
		workMinutes = 60;
		breakMinutes = 5;
		
		// Boolean that gets flipped on if the user changes a setting
		BOOL changed = YES;
		
		// Boolean that gets flipped if user disables notifications
		BOOL cancelled = NO;
		
		// Create temporary button to flip to "settings" scene
		CCMenuItemFont *button = [CCMenuItemFont itemFromString:@"Done!" block:^(id sender) {
			
			if (changed && !cancelled)
			{
				// Cancel previously scheduled notifications
				[[UIApplication sharedApplication] cancelAllLocalNotifications];
				
				// Create all the notification objects before transitioning back to clock
				[self setUpNotifications];
			}
			
			if (cancelled)
			{
				// Cancel previously scheduled notifications
				[[UIApplication sharedApplication] cancelAllLocalNotifications];
			}
			
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:1.0 scene:[HelloWorldLayer scene]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		button.color = ccc3(255, 255, 255);
		
		CCMenu *menu = [CCMenu menuWithItems:button, nil];
		menu.position = ccp(windowSize.width / 2, button.contentSize.height);
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
	for (int i = 0; i < kMaxNotificationLimit; i++)
	{
		// Create date obj that will be used for our reminder
		NSDate *notificationTime;
		if (i != 0)
		{
			// All subsequent notifications include the "break" duration as well
			notificationTime = [NSDate dateWithTimeIntervalSinceNow:(workMinutes + breakMinutes) * 60];
		}
		else
		{
			// Schedule first notification to be after just the "work" duration
			notificationTime = [NSDate dateWithTimeIntervalSinceNow:workMinutes * 60];
		}
		
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
		notification.applicationIconBadgeNumber = 1;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		[notification release];
	}
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
