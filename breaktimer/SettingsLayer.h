//
//  SettingsLayer.h
//  breaktimer
//
//  Created by Nathan Demick on 10/23/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"
#import "CCSlider.h"

@interface SettingsLayer : CCLayer <CCSliderControlDelegate>
{
	// Two vars that hold the amount of time we want to work/break
    int workMinutes, breakMinutes;
	
	CCLabelTTF *workSliderLabel, *breakSliderLabel;
	
	// Boolean that gets flipped on if the user changes a setting
	BOOL settingsHaveChanged;
	
	// Boolean that gets flipped if user disables notifications
	BOOL cancelNotifications;
}

+ (CCScene *)scene;
- (void)setUpNotificationWithRepeat:(BOOL)shouldRepeat;

@end
