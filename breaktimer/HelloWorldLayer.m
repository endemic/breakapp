//
//  HelloWorldLayer.m
//  breaktimer
//
//  Created by Nathan Demick on 10/21/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SettingsLayer.h"
#import "GameConfig.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:kClockLayer];
	
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
		
		static BOOL appJustStarted = YES;
		
		// Add background
		CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
		bg.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:bg];
		
		// Add clock face
		CCSprite *face = [CCSprite spriteWithFile:[NSString stringWithFormat:@"clock-face%@.png", hdSuffix]];
		face.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:face z:1];
		
		// Add hour hand
		hourHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"hour-hand%@.png", hdSuffix]];
		hourHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:hourHand z:3];
		
		// Add minute hand
		minuteHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"minute-hand%@.png", hdSuffix]];
		minuteHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:minuteHand z:3];
		
		// Add second hand
		secondHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"second-hand%@.png", hdSuffix]];
		secondHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:secondHand z:3];
				
		// Add hands that show the next break
		breakHourHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"grey-hour-hand%@.png", hdSuffix]];
		breakHourHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		breakHourHand.opacity = 0;
		[self addChild:breakHourHand z:2];
		
		breakMinuteHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"grey-minute-hand%@.png", hdSuffix]];
		breakMinuteHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		breakMinuteHand.opacity = 0;
		[self addChild:breakMinuteHand z:2];
		
		// If this is the first run, have the clock hands fade in so the transition isn't as jarring
		if (appJustStarted)
		{
			secondHand.opacity = 0;
			minuteHand.opacity = 0;
			hourHand.opacity = 0;
			
			[secondHand runAction:[CCFadeIn actionWithDuration:0.5]];
			[minuteHand runAction:[CCFadeIn actionWithDuration:0.5]];
			[hourHand runAction:[CCFadeIn actionWithDuration:0.5]];
			
			appJustStarted = NO;
		}
		
		// Schedule update loop
		[self scheduleUpdate];
		
		// Set the correct time
		[self setClockHands];
		
		// Set correct position for next break
		[self setBreakHands];

		// Create temporary button to flip to "settings" scene
		CCMenuItemImage *settingsButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"settings-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"settings-button-selected%@.png", hdSuffix] block:^(id sender) {
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:1.0 scene:[SettingsLayer scene]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenu *menu = [CCMenu menuWithItems:settingsButton, nil];
		menu.position = ccp(windowSize.width - settingsButton.contentSize.width, settingsButton.contentSize.height - 2);
		[self addChild:menu];
	}
	return self;
}

- (void)update:(ccTime)dt
{
	ticks += dt;
	
	// Update rotation of clock face
	secondHand.rotation += dt * 6;
	minuteHand.rotation += dt / 10;	// * 6 / 60
	hourHand.rotation += dt / 600;	// * 6 / 60 / 60
	
//	CCLOG(@"Incrementing the hour hand by %f", dt / 600);
}

/**
 * Call to move the clock hands to the appropriate position after long periods of inactivity
 */
- (void)setClockHands
{
	// Get current date/time
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	
	// Break apart into hours/minutes/seconds components
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
	
	int hour = [components hour];
	int minute = [components minute];
	int second = [components second];
	
	// initialize rotation of hands to current time
	// 1 second = 6 degrees
	// 1 minute = 6 degrees
	// 1 hour = 30 degrees
	secondHand.rotation = second * 6;
	minuteHand.rotation = (minute * 6) + (second * 6 / 60);	// Plus percentage of seconds
	hourHand.rotation = (hour % 12) * 30 + (minute * 30 / 60) + (second * 6 / 60);	// Plus percentage of minutes + seconds
}

/**
 * Move the "break" hands to correct initial positions
 */
- (void)setBreakHands
{
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	
	if ([notifications count] > 0)
	{
		// Get the fireDate of the first notification
		UILocalNotification *notification = [notifications objectAtIndex:0];
		
		// Break apart into hours/minutes/seconds components
		NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
		NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:notification.fireDate];
		
		int hour = [components hour];
		int minute = [components minute];
		int second = [components second];
		
		breakMinuteHand.rotation = (minute * 6) + (second * 6 / 60);	// Plus percentage of seconds
		breakHourHand.rotation = (hour % 12) * 30 + (minute * 30 / 60) + (second * 6 / 60);	// Plus percentage of minutes + seconds
		
		[breakHourHand runAction:[CCFadeIn actionWithDuration:0.5]];
		[breakMinuteHand runAction:[CCFadeIn actionWithDuration:0.5]];
	}
	else
	{
		NSLog(@"No notifications set!");
		
		// Keep invisible
		breakMinuteHand.opacity = 0;
		breakHourHand.opacity = 0;
	}
}

/**
 * Animate the "break" hands to new positions
 */
- (void)updateBreakHands
{
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	
	if ([notifications count] > 0)
	{
		// Get the fireDate of the first notification
		UILocalNotification *notification = [notifications objectAtIndex:0];
		
		// Break apart into hours/minutes/seconds components
		NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
		NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:notification.fireDate];
		
		int hour = [components hour];
		int minute = [components minute];
		int second = [components second];
		
		int newMinuteAngle = (minute * 6) + (second * 6 / 60);	// Plus percentage of seconds
		int newHourAngle = (hour % 12) * 30 + (minute * 30 / 60) + (second * 6 / 60);	// Plus percentage of minutes + seconds
		
		// Find difference between new position and current position
		int minuteDiff = newMinuteAngle - breakMinuteHand.rotation;
		int hourDiff = newHourAngle - breakHourHand.rotation;
		
		// Ensure that angles are always going "forward"
		if (minuteDiff < 0)
		{
			minuteDiff *= -1;
		}
		
		if (hourDiff < 0)
		{
			hourDiff *= -1;
		}
		
		[breakMinuteHand runAction:[CCRotateBy actionWithDuration:1.0 angle:minuteDiff]];
		[breakHourHand runAction:[CCRotateBy actionWithDuration:1.0 angle:hourDiff]];
	}
	else
	{
		// Fade out
		[breakHourHand runAction:[CCFadeOut actionWithDuration:0.5]];
		[breakMinuteHand runAction:[CCFadeOut actionWithDuration:0.5]];
	}
}

/**
 * Handle clicking of the alert view
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Get the next notification and move the "pending" clock hands to the next break time
	NSLog(@"Received the alert callback from HelloWorldLayer!");
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
