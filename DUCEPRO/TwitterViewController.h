//
//  TwitterViewController.h
//  DUCEPRO
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface TwitterViewController : TWTRTimelineViewController

@property (strong, nonatomic) NSString *searchString;

@end
