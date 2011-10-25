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

@interface SettingsLayer : CCLayer 
{
	// Two vars that hold the amount of time we want to work/break
    int workMinutes, breakMinutes;
}

+ (CCScene *)scene;
- (void)setUpNotifications;

@end
