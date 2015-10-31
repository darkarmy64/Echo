//
//  MusicChatViewController.m
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "MusicChatViewController.h"
#import "RdioTrack.h"
#import "SearchViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "TwitterViewController.h"
#import "MNCChatMessageCell.h"


@interface MusicChatViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,RdioDelegate,RDPlayerDelegate,UITextFieldDelegate>
{
    UIImageView * trackImageView;
    RdioTrack * currentTrack;
    UITapGestureRecognizer * singleTap;
    UITapGestureRecognizer * doubleTap;
    NSString * currentTrackName;
    
    RDPlayer *_player;
    Rdio *_rdio;
    
    BOOL _playing;
    BOOL _paused;
    BOOL _loggedIn;

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

}

- (void)viewDidAppear:(BOOL)animated {

    if (![currentTrack.trackName isEqualToString:@""]) {
        NSLog(@"CURRENT NAME : %@",currentTrack.trackName);
        trackImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentTrack.trackIcon]]];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [_player.queue removeAll];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_RECIEVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_SENT object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
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
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    trackImageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [headerView addSubview:trackImageView];
    [headerView addGestureRecognizer:singleTap];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.view.frame.size.width;

}

# pragma mark Music Player
- (IBAction)playPauseTapped:(id)sender
{
    NSLog(@"Play/pause button tapped!");
    if (!_playing) {
        // Nothing's been "played" yet, so queue up and play something
        [_player.queue add:currentTrack.trackKey];
        [_player playFromQueue:0];
    } else {
        // Otherwise, just toggle play/pause
        [_player togglePause];
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
