//
//  MusicChatViewController.m
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define SWidth self.view.bounds.size.width
#define SHeight self.view.bounds.size.height


#import "MusicChatViewController.h"
#import "RdioTrack.h"
#import "SearchViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "TwitterViewController.h"
#import "MNCChatMessageCell.h"
#import "MusicHeaderView.h"


@interface MusicChatViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,RdioDelegate,RDPlayerDelegate,UITextFieldDelegate>
{
    UIImageView * trackImageView;
    RdioTrack * currentTrack;
    UITapGestureRecognizer * singleTap;
    UITapGestureRecognizer * doubleTap;
    NSString * currentTrackName;
	
	MusicHeaderView *musicHeaderView;
    
    RDPlayer *_player;
    Rdio *_rdio;
    
    BOOL _playing;
    BOOL _paused;
    BOOL _loggedIn;
    
    NSTimer *timer;

}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *messageEditField;

@end

@implementation MusicChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentTrack = [[RdioTrack alloc] init];
    _myTableView.backgroundColor = UIColorFromRGB(0xECF0F1);
    
    _rdio = [AppDelegate sharedRdio];
    [_rdio setDelegate:self];
    _player = [_rdio preparePlayerWithDelegate:self];
	
    self.navigationItem.title = self.chatMateId;
    self.messageArray = [[NSMutableArray alloc] init];
    
	/* Push Twitter VC
	TwitterViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterVC"];
	tvc.searchString = @"SearchString";
	[self.navigationController pushViewController:tvc animated:YES];
	 */
    // Automatically determine the height of each self-sizing tabel view cells - an iOS 8 feature
    self.myTableView.rowHeight = UITableViewAutomaticDimension;     /* add this line */
    [self retrieveMessagesFromParseWithChatMateID:self.chatMateId];
    UITapGestureRecognizer *tapTableGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.myTableView addGestureRecognizer:tapTableGR];
    [self registerForKeyboardNotifications];
	
	if (!musicHeaderView) {
		musicHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MusicHeaderView" owner:self options:nil] firstObject];
		[musicHeaderView setPlaying:NO];
		[musicHeaderView.playPauseButton addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventAllEvents];
	}
    
//    [self refreshTrack];
    
//     timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
//    [timer fire];

}

-(void)timerDidFire:(NSTimer *)timer {
    [self refreshTrack];
}

- (void)viewDidAppear:(BOOL)animated {

    if (![currentTrack.trackName isEqualToString:@""]) {
        NSLog(@"CURRENT NAME : %@",currentTrack.trackName);
//        trackImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentTrack.trackIcon]]];
		musicHeaderView.songNameLabel.text = currentTrack.trackName;
		musicHeaderView.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ | %@", currentTrack.trackArtist, currentTrack.trackAlbum];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentTrack.trackIcon]]];
			dispatch_async(dispatch_get_main_queue(), ^{
				musicHeaderView.albumCoverImageView.image = image;
			});
		});
		[musicHeaderView setPlaying:NO];
    }
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
//    [self refreshTrack];

}

- (void)viewDidDisappear:(BOOL)animated {
    [_player.queue removeAll];
    [timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_RECIEVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_SENT object:nil];
//    [self refreshTrack];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self.activeTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helper Methods

- (void)didTapOnTableView {
    [self.activeTextField resignFirstResponder];
}


// Setting up keyboard notifications.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(kbSize.height, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (void)receiveMessage:(RdioTrack *)track {
    currentTrack = track;
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    NSMutableDictionary *rowOfData = [NSMutableDictionary dictionaryWithDictionary:@{@"recipient_id" : self.chatMateId, @"sender_id" : self.myUserId, @"current_track" : currentTrack.trackKey, @"track_name" : currentTrack.trackName}];
    MSTable *database = [client tableWithName:@"SongStore"];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"recipient_id == %@ AND sender_id == %@", self.chatMateId, self.myUserId];
    
    [database readWithPredicate:predicate completion:^(MSQueryResult *result, NSError *error) {
        if(error) { // error is nil if no error occured
            NSLog(@"ERROR %@", error);
        }
        
        else {
            if(result.items.count > 0) {
                // Update
                NSMutableDictionary *newRowOfData = [result.items lastObject];
                newRowOfData[@"track_name"] = currentTrack.trackName;
                newRowOfData[@"current_track"] = currentTrack.trackKey;
                [database update:newRowOfData completion:^(NSDictionary *item, NSError *error) {
                    if (error) {
                        NSLog(@"Error Update: %@", error);
                    } else {
                        NSLog(@"Item updated FTGOSE, id: %@\n%@\n%@\n%@", [item objectForKey:@"recipient_id"], [item objectForKey:@"sender_id"], [item objectForKey:@"current_track"], [item objectForKey:@"track_name"]);
                    }
//                     [self refreshTrack];
                }];
                
            }
            else {
                // Add
                [database insert:rowOfData completion:^(NSDictionary *insertedItem, NSError *error) {
                    if (error) {
                        NSLog(@"Error Insert: %@", error);
                    } else {
                        NSLog(@"Item inserted, id: %@\n%@\n%@\n%@", [insertedItem objectForKey:@"recipient_id"], [insertedItem objectForKey:@"sender_id"], [insertedItem objectForKey:@"current_track"], [insertedItem objectForKey:@"track_name"]);
                    }
//                     [self refreshTrack];
                }];
            }
        }
        
    }];
    
    
    
    NSMutableDictionary *rowOfDataX = [rowOfData mutableCopy];
    rowOfDataX[@"sender_id"] = rowOfData[@"recipient_id"];
    rowOfDataX[@"recipient_id"] = rowOfData[@"sender_id"];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"recipient_id == %@ AND sender_id == %@", self.myUserId, self.chatMateId];
    
    [database readWithPredicate:predicate2 completion:^(MSQueryResult *result, NSError *error) {
        if(error) { // error is nil if no error occured
            NSLog(@"ERROR %@", error);
        }
        
        else {
            if(result.items.count > 0) {
                // Update
                NSMutableDictionary *newRowOfData = [result.items lastObject];
                newRowOfData[@"track_name"] = currentTrack.trackName;
                newRowOfData[@"current_track"] = currentTrack.trackKey;
                [database update:newRowOfData completion:^(NSDictionary *item, NSError *error) {
                    if (error) {
                        NSLog(@"Error Update 2: %@", error);
                    } else {
                        NSLog(@"Item updated FTGOSE, id: %@\n%@\n%@\n%@", [item objectForKey:@"recipient_id"], [item objectForKey:@"sender_id"], [item objectForKey:@"current_track"], [item objectForKey:@"track_name"]);
                    }
                    [self refreshTrack];
                }];
                
            }
            else {
                // Add
                [database insert:rowOfDataX completion:^(NSDictionary *insertedItem, NSError *error) {
                    if (error) {
                        NSLog(@"Error Insert 2: %@", error);
                    } else {
                        NSLog(@"Item inserted, id: %@\n%@\n%@\n%@", [insertedItem objectForKey:@"recipient_id"], [insertedItem objectForKey:@"sender_id"], [insertedItem objectForKey:@"current_track"], [insertedItem objectForKey:@"track_name"]);
                    }
                    [self refreshTrack];
                }];
            }
        }
        
    }];
     
    

    
//    [database insert:rowOfData completion:^(NSDictionary *insertedItem, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Item inserted, id: %@\n%@\n%@\n%@", [insertedItem objectForKey:@"recipient_id"], [insertedItem objectForKey:@"sender_id"], [insertedItem objectForKey:@"current_track"], [insertedItem objectForKey:@"track_name"]);
//        }
//    }];
    
}

- (void)refreshTrack
{
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    MSTable *database = [client tableWithName:@"SongStore"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"recipient_id == %@ AND sender_id == %@", self.myUserId, self.chatMateId];
    [database readWithPredicate:predicate completion:^(MSQueryResult *result, NSError *error) {
        if(error) { // error is nil if no error occured
            NSLog(@"ERROR %@", error);
        } else {
            NSDictionary *item = [result.items lastObject];
            NSLog(@"Refreshing item: %@\n%@\n%@\n%@", [item objectForKey:@"recipient_id"], [item objectForKey:@"sender_id"], [item objectForKey:@"current_track"], [item objectForKey:@"track_name"]);
            
            if (!(item == nil || [[item objectForKey:@"track_name"] isKindOfClass:[NSNull class]]))
            {
                [_player stop];
                [_player.queue removeAll];
                [_player.queue add:item];
                
                [_rdio callAPIMethod:@"search" withParameters:@{@"query":[item objectForKey:@"track_name"],
                                                                @"types":@"Track"}
                             success:^(NSDictionary *resultx) {
                                 NSMutableArray * tempMutableArray = [NSMutableArray new];
                                 tempMutableArray = [resultx objectForKey:@"results"];
                                 for (NSDictionary * trackObject in tempMutableArray) {
                                     RdioTrack * track = [[RdioTrack alloc] initWithDict:trackObject];
                                     if ([track.trackKey isEqualToString:[item objectForKey:@"current_track"]] ) {
                                         NSLog(@"Updating track info From OtherUser...");
                                         currentTrack = track;
                                         [self viewDidAppear:YES];
                                     }
                                 }
                             } failure:^(NSError *error) {
                                 
                             }];
                
            }
            /*
            for(NSDictionary *item in result.items) { // items is NSArray of records that match query
                NSLog(@"Todo Item: %@\n%@\n%@\n%@", [item objectForKey:@"recipient_id"], [item objectForKey:@"sender_id"], [item objectForKey:@"current_track"], [item objectForKey:@"track_name"]);
                if (item == nil || [[item objectForKey:@"track_name"] isKindOfClass:[NSNull class]])
                {
                    break;
                }
                else if ([[item objectForKey:@"current_track"] isEqualToString:currentTrack.trackKey])
                {
                    break;
                }
                else
                {
                    // if currently present track in the app is not the same as the one on the DB
                    // The other user/receipent has changed the track
                    [_player stop];
                    [_player.queue removeAll];
                    [_player.queue add:item];
                    [_rdio callAPIMethod:@"search" withParameters:@{@"query":[item objectForKey:@"track_name"],
                                                                    @"types":@"Track"}
                                 success:^(NSDictionary *resultx) {
                                     NSMutableArray * tempMutableArray = [NSMutableArray new];
                                     tempMutableArray = [resultx objectForKey:@"results"];
                                     for (NSDictionary * trackObject in tempMutableArray) {
                                         RdioTrack * track = [[RdioTrack alloc] initWithDict:trackObject];
                                         if ([track.trackKey isEqualToString:[item objectForKey:@"current_track"]] ) {
                                             NSLog(@"Updating track info...");
                                             currentTrack = track;
                                             [self viewDidAppear:YES];
                                         }
                                     }
                                 } failure:^(NSError *error) {
                                     
                                 }];
                }
            }
             */
        }

    }];
    
//    [database readWithCompletion:^(MSQueryResult *result, NSError *error) {
//        if(error) { // error is nil if no error occured
//            NSLog(@"ERROR %@", error);
//        } else {
//            for(NSDictionary *item in result.items) { // items is NSArray of records that match query
//                NSLog(@"Todo Item: %@\n%@\n%@", [item objectForKey:@"recipient_id"], [item objectForKey:@"sender_id"], [item objectForKey:@"current_track"]);
//            }
//        }
//    }];
    
}

- (IBAction)openSearchView:(id)sender {
    
    [self performSegueWithIdentifier:@"searchView" sender:self];

}


- (void)retrieveMessagesFromParseWithChatMateID:(NSString *)chatMateId {
    NSArray *userNames = @[self.myUserId, chatMateId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SinchMessage"];
    [query whereKey:@"senderId" containedIn:userNames];
    [query whereKey:@"recipientId" containedIn:userNames];
    [query orderByAscending:@"timestamp"];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *chatMessageArray, NSError *error) {
        if (!error) {
            // Store all retrieve messages into messageArray
            for (int i = 0; i < [chatMessageArray count]; i++) {
                MNCChatMessage *chatMessage = [[MNCChatMessage alloc] init];
                
                [chatMessage setMessageId:chatMessageArray[i][@"messageId"]];
                [chatMessage setSenderId:chatMessageArray[i][@"senderId"]];
                [chatMessage setRecipientIds:[NSArray arrayWithObject:chatMessageArray[i][@"recipientId"]]];
                [chatMessage setText:chatMessageArray[i][@"text"]];
                [chatMessage setTimestamp:chatMessageArray[i][@"timestamp"]];
                
                [weakSelf.messageArray addObject:chatMessage];
            }
            [weakSelf.myTableView reloadData];  // Refresh the table view
            [weakSelf scrollTableToBottom];  // Scroll to the bottom of the table view
            [self refreshTrack];
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}



- (void)sendMessage:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSLog(@"MESSAGE ON TEXT FIELD: %@",self.messageEditField.text);
    [appDelegate sendTextMessage:self.messageEditField.text toRecipient:self.chatMateId];
}

- (void)messageDelivered:(NSNotification *)notification
{
    MNCChatMessage *chatMessage = [[notification userInfo] objectForKey:@"message"];
    NSLog(@"MESSAGE : %@",chatMessage.text);
    [self.messageArray addObject:chatMessage];
    [self.myTableView reloadData];
    [self scrollTableToBottom];
}

- (void)scrollTableToBottom {
    int rowNumber = (int)[self.myTableView numberOfRowsInSection:0];
    if (rowNumber > 0) [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNCChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"MessageListPrototypeCell" forIndexPath:indexPath];
    [self configureCell:messageCell forIndexPath:indexPath];
    
    return messageCell;

}

- (void)configureCell:(MNCChatMessageCell *)messageCell forIndexPath:(NSIndexPath *)indexPath {
    
    MNCChatMessage *chatMessage = self.messageArray[indexPath.row];
    
    if ([[chatMessage senderId] isEqualToString:self.myUserId]) {
        // If the message was sent by myself
        messageCell.chatMateMessageLabel.text = @"";
        messageCell.myMessageLabel.text = chatMessage.text;
    } else {
        // If the message was sent by the chat mate
        messageCell.myMessageLabel.text = @"";
        messageCell.chatMateMessageLabel.text = chatMessage.text;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
//    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
//    trackImageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
	singleTap.cancelsTouchesInView = NO;
//    [headerView addSubview:trackImageView];
//    [headerView addGestureRecognizer:singleTap];
//    return headerView;
	
	if (!musicHeaderView) {
		musicHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MusicHeaderView" owner:self options:nil] firstObject];
		[musicHeaderView setFrame:CGRectMake(0, 0, SWidth, SWidth)];
		[musicHeaderView setPlaying:NO];
		musicHeaderView.albumCoverImageView.clipsToBounds = YES;
		[musicHeaderView.playPauseButton addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventAllEvents];
	}
	
//	musicHeaderView.albumCoverImageView.image = [UIImage imageNamed:@"MX.jpg"];
//	musicHeaderView.albumCoverImageView = trackImageView;
	
	[musicHeaderView addGestureRecognizer:singleTap];
	
	return musicHeaderView;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	CGFloat offsety = self.myTableView.contentOffset.y;
//	CGFloat minHeight = 120.f;
//    return MAX(minHeight, SWidth - offsety);
	if (![currentTrack.trackName isEqualToString:@""])
		return SWidth;
	return 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.activeTextField resignFirstResponder];
//	CGFloat offsety = self.myTableView.contentOffset.y;
//	CGFloat minHeight = 120.f;
//	[self.myTableView beginUpdates];
//	[musicHeaderView setFrame:CGRectMake(0, 64, SWidth, MAX(minHeight, SWidth - offsety))];
//	[musicHeaderView layoutIfNeeded];
//	[musicHeaderView layoutSubviews];
//	[self.myTableView reloadData];
//	[self.myTableView endUpdates];
}

# pragma mark Music Player
- (IBAction)playPauseTapped:(id)sender
{
    NSLog(@"Play/pause button tapped!");
    if (!_playing) {
        // Nothing's been "played" yet, so queue up and play something
        [_player.queue add:currentTrack.trackKey];
        [_player playFromQueue:0];
		[musicHeaderView setPlaying:YES];
		musicHeaderView.playState = PlayStatePaused;
    } else {
        // Otherwise, just toggle play/pause
        [_player togglePause];
		if (musicHeaderView.playState == PlayStatePaused)
			[musicHeaderView setPlaying:YES];
		else
			[musicHeaderView setPlaying:NO];
    }
}

- (void)setLoggedIn:(BOOL)loggedIn
{
    _loggedIn = loggedIn;
    
    NSString *buttonTitle;
    if (_loggedIn) {
        buttonTitle = @"Disconnect Rdio";
    } else {
        buttonTitle = @"Connect to Rdio";
    }
//    [_loginButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    // Re-initialize the player on login changes
    _player = [_rdio preparePlayerWithDelegate:self];
}


#pragma mark - RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user
{
    NSLog(@"authorized user %@", user);
    [self setLoggedIn:YES];
}

- (void)rdioAuthorizationFailed:(NSError *)error
{
    NSLog(@"authorization failed: %@", error);
    [self setLoggedIn:NO];
}

- (void)rdioAuthorizationCancelled
{
    NSLog(@"The user cancelled authorization");
    [self setLoggedIn:NO];
}

-(void)rdioDidLogout
{
    NSLog(@"Logged out");
    [self setLoggedIn:NO];
}


#pragma mark - RDPlayerDelegate
-(BOOL)rdioIsPlayingElsewhere
{
    return NO;
}

- (void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    NSLog(@"Rdio Player changed from state %u to state %u", oldState, newState);
    
    // Your internal state machine logic may differ, but for the sake of simplicity,
    // this Hello app considers Playing, Paused, and Buffering all as "playing" states.
    _playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
    _paused = (newState == RDPlayerStatePaused);
    
    if (_paused || !_playing) {
//        [_playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
//        [_playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"searchView"]) {
    UINavigationController * navController = [segue destinationViewController];
    SearchViewController *secondVC = [navController viewControllers][0];
    MusicChatViewController *firstVC = [segue sourceViewController];
    secondVC.delegate = firstVC;
//    }
}

@end
