//
//  SearchViewController.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicChatViewController.h"

@class MusicChatViewController;

@interface SearchViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISearchBar *trackSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *trackTableView;

@property (weak, nonatomic) id<FirstVCDelegate> delegate;

@end
