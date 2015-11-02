//
//  FavouritesTableViewController.m
//  DUCEPRO
//
//  Created by YASH on 02/11/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "Favourites.h"
#import "Favourites+CoreDataProperties.h"
#import "RdioTrack.h"
#import "SearchTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MusicHeaderView.h"
#import "TwitterViewController.h"

@interface FavouritesTableViewController () <RdioDelegate,RDPlayerDelegate>
{
    NSMutableArray *favouritesArray;
	
	RdioTrack * currentTrack;
	
	MusicHeaderView *musicHeaderView;
	
	RDPlayer *_player;
	Rdio *_rdio;
	
	CAGradientLayer *gradient;
}

@end

@implementation FavouritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	favouritesArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Favourites"];
    NSError *error = nil;
    
    NSArray *fetchedTrackArray = [[Favourites managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    favouritesArray = [fetchedTrackArray mutableCopy];
    
    [self.tableView reloadData];
	
	_rdio = [AppDelegate sharedRdio];
	[_rdio.player stop];
	[_rdio setDelegate:self];
	_player = [_rdio preparePlayerWithDelegate:self];
	

	if (!musicHeaderView) {
		musicHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MusicHeaderView" owner:self options:nil] firstObject];
		[musicHeaderView setPlaying:NO];
		[musicHeaderView.playPauseButton addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventAllEvents];
		[musicHeaderView.twitterButton addTarget:self action:@selector(twitterAction:) forControlEvents:UIControlEventTouchUpInside];
		[musicHeaderView.favButton setHidden:YES];
	}
	
	if (!currentTrack) {
		if (favouritesArray.count > 0) {
			currentTrack = [favouritesArray firstObject];
			[self updatePlayer];
		}
		else
			currentTrack = nil;
	}
	
	[musicHeaderView setPlaying:NO];
	
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
	self.navigationController.view.backgroundColor = [UIColor clearColor];
	
	if (!gradient) {
		gradient = [CAGradientLayer layer];
		gradient.frame = CGRectMake(0, -20, SWidth, 64);
		gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
	}
	[self.navigationController.navigationBar.layer insertSublayer:gradient atIndex:1];
	
	self.tableView.contentOffset = CGPointMake(0, 64);
}

-(void)viewDidDisappear:(BOOL)animated {
	[_rdio.player stop];
	[_player stop];
	[_player.queue removeAll];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.backgroundColor = GLOBAL_BACK_COLOR;
	self.navigationController.view.backgroundColor = GLOBAL_BACK_COLOR;
	
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	
	[gradient removeFromSuperlayer];
}

- (void) updatePlayer {
	
	[_player stop];
	[_player.queue removeAll];
	
	[musicHeaderView setPlaying:NO];
	
	musicHeaderView.songNameLabel.text = @"";
	musicHeaderView.artistAlbumLabel.text = @"";
	
	if (currentTrack) {
		NSLog(@"CURRENT NAME : %@",currentTrack.trackName);
		musicHeaderView.songNameLabel.text = currentTrack.trackName;
		musicHeaderView.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ | %@", currentTrack.trackArtist, currentTrack.trackAlbum];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentTrack.trackIcon]]];
			dispatch_async(dispatch_get_main_queue(), ^{
				musicHeaderView.albumCoverImageView.image = image;
			});
		});
		[musicHeaderView setPlaying:NO];
		
		[_player.queue add:currentTrack.trackKey];
		
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favouritesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"favCell";
    
    RdioTrack *thisTrack = [favouritesArray objectAtIndex:indexPath.row];
	
	SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	if (cell == nil)
		cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	cell.trackNameLabel.text = thisTrack.trackName;
	cell.trackAlbumLabel.text = [NSString stringWithFormat:@"%@ | %@", thisTrack.trackArtist, thisTrack.trackAlbum];
	[cell.trackCoverImageView sd_setImageWithURL:[NSURL URLWithString:thisTrack.trackIcon] placeholderImage:[UIImage imageNamed:@"tux_duce.png"]];
	
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_player stop];
	[_player.queue removeAll];
	RdioTrack *thisTrack = [favouritesArray objectAtIndex:indexPath.row];
	currentTrack = thisTrack;
	[self updatePlayer];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (!musicHeaderView) {
		musicHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MusicHeaderView" owner:self options:nil] firstObject];
		[musicHeaderView setFrame:CGRectMake(0, 0, SWidth, SWidth)];
		[musicHeaderView setPlaying:NO];
		musicHeaderView.albumCoverImageView.clipsToBounds = YES;
		[musicHeaderView.playPauseButton addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventAllEvents];
		[musicHeaderView.twitterButton addTarget:self action:@selector(twitterAction:) forControlEvents:UIControlEventTouchUpInside];
		[musicHeaderView.favButton setHidden:YES];
	}
	
	return musicHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return SWidth;
}

#pragma mark - Dismiss


- (IBAction)dismissVC:(id)sender {
	[self dismissViewControllerAnimated:YES
							 completion:nil];
}

#pragma mark - Music Player

- (IBAction)playPauseTapped:(id)sender
{
	NSLog(@"Play/pause button tapped!");
	if (!(_player.state == RDPlayerStatePlaying)) {
		// Nothing's been "played" yet, so queue up and play something
		[_player.queue add:currentTrack.trackKey];
		[_player playFromQueue:0];
		[musicHeaderView setPlaying:YES];
		musicHeaderView.playState = PlayStatePaused;
	}
	else {
		[_player togglePause];
		if (musicHeaderView.playState == PlayStatePaused)
			[musicHeaderView setPlaying:YES];
		else
			[musicHeaderView setPlaying:NO];
	}
}

#pragma mark - Other

-(void)twitterAction:(id)sender {
	//  Twitter VC
	if (!([currentTrack.trackName isEqualToString:@""] || [currentTrack.trackName isKindOfClass:[NSNull class]])) {
		TwitterViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterVC"];
		tvc.songName = currentTrack.trackName;
		NSString *artistTag = ([currentTrack.trackArtist isKindOfClass:[NSNull class]])?@"":[NSString stringWithFormat:@"#%@",[currentTrack.trackArtist stringByReplacingOccurrencesOfString:@" " withString:@""]];
		tvc.searchString = [NSString stringWithFormat:@"#%@ %@", [currentTrack.trackName stringByReplacingOccurrencesOfString:@" " withString:@""], artistTag];
		[self.navigationController pushViewController:tvc animated:YES];
	}
}

/* 
// Add removal code and shit
-(void)favAction:(id)sender {
	
	NSFetchRequest *fetchRequestx = [NSFetchRequest fetchRequestWithEntityName:@"Favourites"];
	NSError *error = nil;
	
	NSManagedObjectContext * context = [Favourites managedObjectContext];
	
	NSArray *fetchedArray = [context executeFetchRequest:fetchRequestx error:&error];
	BOOL trackAlreadyThere = NO;
	
	for (int i=0; i<fetchedArray.count; i++)
	{
		RdioTrack *track = [fetchedArray objectAtIndex:i];
		if ([track.trackKey isEqualToString:currentTrack.trackKey])
		{
			trackAlreadyThere = YES;
			[context deleteObject:(NSManagedObject *)track];
			break;
		}
	}
	
	if (trackAlreadyThere == NO)
	{
		
		Favourites *favouritedTrack = [NSEntityDescription insertNewObjectForEntityForName:@"Favourites" inManagedObjectContext:context];
		
		favouritedTrack.trackKey = currentTrack.trackKey;
		favouritedTrack.trackName = currentTrack.trackName;
		favouritedTrack.trackUrl = currentTrack.trackName;
		favouritedTrack.trackIcon = currentTrack.trackIcon;
		favouritedTrack.trackArtist = currentTrack.trackArtist;
		favouritedTrack.trackAlbum = currentTrack.trackAlbum;
		
	}
	
	if (![context save:&error])
	{
		
		NSLog(@"%@",error);
		
	}
	
	[self viewDidLoad];
	
}
 */

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
	BOOL playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
	BOOL paused = (newState == RDPlayerStatePaused);
	
	if (paused || !playing) {
		[musicHeaderView setPlaying:NO];
		//        [_playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
	} else {
		[musicHeaderView setPlaying:YES];
		//        [_playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
