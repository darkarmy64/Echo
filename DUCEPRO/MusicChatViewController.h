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

@protocol FirstVCDelegate <NSObject>
- (void)receiveMessage:(RdioTrack *)track;
@end

@interface MusicChatViewController : UIViewController <FirstVCDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)openSearchView:(id)sender;

@end
