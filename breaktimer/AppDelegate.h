//
//  AppDelegate.h
//  breaktimer
//
//  Created by Nathan Demick on 10/21/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
