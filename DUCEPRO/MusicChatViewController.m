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

@interface MusicChatViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,RdioDelegate,RDPlayerDelegate>
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
	
	/* Push Twitter VC
	TwitterViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterVC"];
	tvc.searchString = @"SearchString";
	[self.navigationController pushViewController:tvc animated:YES];
	 */
	
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helper Methods

- (void)receiveMessage:(RdioTrack *)track {
    currentTrack = track;
}

- (IBAction)openSearchView:(id)sender {
    
    [self performSegueWithIdentifier:@"searchView" sender:self];

}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    return cell;
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
