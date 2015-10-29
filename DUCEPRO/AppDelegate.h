//
//  AppDelegate.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 28/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (Rdio *)sharedRdio;

@end

