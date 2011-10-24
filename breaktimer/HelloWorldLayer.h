//
//  HelloWorldLayer.h
//  breaktimer
//
//  Created by Nathan Demick on 10/21/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <UIAlertViewDelegate>
{
	// Store clock hands
	CCSprite *hourHand, *minuteHand, *secondHand;
	
	// Store milliseconds that elapse per frame
	ccTime ticks;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
