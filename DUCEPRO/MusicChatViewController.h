//
//  MusicChatViewController.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RdioTrack.h"
#import <Rdio/Rdio.h>
#import "MNCChatMessage.h"

@protocol FirstVCDelegate <NSObject>
- (void)receiveMessage:(RdioTrack *)track;
@end

@interface MusicChatViewController : UIViewController <FirstVCDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)openSearchView:(id)sender;


@property (strong, nonatomic) NSString *chatMateId;
@property (strong, nonatomic) NSString *myUserId;
@property (strong, nonatomic) NSMutableArray* messageArray;
@property (strong, nonatomic) UITextField *activeTextField;
- (IBAction)sendMessage:(id)sender;


@end
