//
//  AppDelegate.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 28/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
#import "SVProgressHUD.h"
#import <Parse/Parse.h>
#import "Config.h"
#import <Sinch/Sinch.h>
#import "Config.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#define SWidth [UIScreen mainScreen].bounds.size.width
#define SHeight [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define GLOBAL_TINT_COLOR UIColorFromRGBWithAlpha(0xfcf9ee, 1.f)
#define GLOBAL_BACK_COLOR UIColorFromRGBWithAlpha(0x111100, 1.f)

#define SHOW_ALERT(alertMessage) [[[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];

#define SHOW_ALERT_IN_MAIN_QUEUE(alertMessage) dispatch_async(dispatch_get_main_queue(), ^{ SHOW_ALERT(alertMessage) });


@interface AppDelegate : UIResponder <UIApplicationDelegate,SINClientDelegate,SINMessageClientDelegate>

@property (strong, nonatomic) id<SINClient> sinchClient;
@property (strong, nonatomic) UIWindow *window;
+ (Rdio *)sharedRdio;
- (void)initSinchClient:(NSString*)userId;
@property (strong, nonatomic) id<SINMessageClient> sinchMessageClient;
- (void)sendTextMessage:(NSString *)messageText toRecipient:(NSString *)recipientId;
@property (strong, nonatomic) MSClient *client;

@end

