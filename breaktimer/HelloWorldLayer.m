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
		[self addChild:hourHand z:2];
		
		// Add hour hand
		minuteHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"minute-hand%@.png", hdSuffix]];
		minuteHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:minuteHand z:3];
		
		// Add second hand
		secondHand = [CCSprite spriteWithFile:[NSString stringWithFormat:@"second-hand%@.png", hdSuffix]];
		secondHand.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:secondHand z:3];
		
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
		hourHand.rotation = (hour % 12) * 30 + (minute * 30 / 60) + (second * 6 / 60);
		
		// Get the next scheduled notification
//		NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
		
		// TODO: move the "pending" clock hands to the next break time
		
		// Create temporary button to flip to "settings" scene
		CCMenuItemFont *button = [CCMenuItemFont itemFromString:@"i" block:^(id sender) {
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:1.0 scene:[SettingsLayer scene]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		button.color = ccc3(255, 255, 255);
		
		CCMenu *menu = [CCMenu menuWithItems:button, nil];
		menu.position = ccp(windowSize.width - button.contentSize.width, button.contentSize.height);
		[self addChild:menu];
	}
	return self;
}

- (void)update:(ccTime)dt
{
	ticks += dt;
	
//	NSLog(@"Delta time: %f", dt);
	
	// Update rotation of clock face
	secondHand.rotation += dt * 6;
	minuteHand.rotation += dt / 10;	// * 6 / 60
	hourHand.rotation += dt / 600;	// * 6 / 60 / 60
	
	CCLOG(@"Incrementing the hour hand by %f", dt / 600);
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
