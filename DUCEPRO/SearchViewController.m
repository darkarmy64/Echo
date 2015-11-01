//
//  SearchViewController.m
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "SearchViewController.h"
#import <Rdio/Rdio.h>
#import <Rdio/RDAPIRequest.h>
#import "AppDelegate.h"
#import "RdioTrack.h"
#import "UIImageView+WebCache.h"
#import "SearchTableViewCell.h"
#import "SCSiriWaveformView.h"

@interface SearchViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RdioDelegate>
{
     Rdio *_rdio;
	
	BOOL searching;
}
@property NSMutableArray * trackArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rdio = [AppDelegate sharedRdio];
    [_rdio setDelegate:self];
	
	_trackSearchBar = [[UISearchBar alloc] init];
	[_trackSearchBar sizeToFit];
	[_trackSearchBar setDelegate:self];
	[_trackSearchBar setPlaceholder:@"Search"];
	[_trackSearchBar setSearchBarStyle:UISearchBarStyleMinimal];
	[_trackSearchBar setTintColor:GLOBAL_TINT_COLOR];
	[_trackSearchBar setBarTintColor:GLOBAL_TINT_COLOR];
	[_trackSearchBar setKeyboardAppearance:UIKeyboardAppearanceDark];
//	[_trackSearchBar setShowsCancelButton:YES];
	
	[self.navigationItem setTitleView:_trackSearchBar];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissVC)];
	self.navigationItem.leftBarButtonItem = doneButton;
	
//	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVC)];
//	[self.view addGestureRecognizer:tapGesture];
}

-(void)dismissVC {
	[self resignFirstResponder];
	[self.trackSearchBar resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
	[self.trackSearchBar becomeFirstResponder];
	searching = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll view delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.trackSearchBar resignFirstResponder];
	[self resignFirstResponder];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trackArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"SearchCell";
    
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	if (cell == nil)
		cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    RdioTrack *track = [_trackArray objectAtIndex:indexPath.row];
	cell.trackNameLabel.text = track.trackName;
	cell.trackAlbumLabel.text = [NSString stringWithFormat:@"%@ | %@", track.trackArtist, track.trackAlbum];
    [cell.trackCoverImageView sd_setImageWithURL:[NSURL URLWithString:track.trackIcon] placeholderImage:[UIImage imageNamed:@"tux_duce.png"]];
     
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RdioTrack * track = [_trackArray objectAtIndex:indexPath.row];
    [self.delegate receiveMessage:track];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * blankView = [[UIView alloc] initWithFrame:CGRectZero];
    return blankView;
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
// 
// // Instead of this add a results count view
//	
//	SCSiriWaveformView *siriView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(0, 0, SWidth, 80)];
//	
//	[siriView setWaveColor:GLOBAL_TINT_COLOR];
//	[siriView setPrimaryWaveLineWidth:1.5f];
//	[siriView setSecondaryWaveLineWidth:1.0];
//	[siriView setIdleAmplitude:0.01];
//	[siriView setFrequency:0.5];
//	[siriView setDensity:10];
//	[siriView setPhaseShift:-0.15];
//	
//	[siriView updateWithLevel:1.0];
//	
//	return siriView;
//
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	if (searching)
//		return 80;
//	return 0;
//}

#pragma mark Search Bar Delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	[self.trackTableView reloadData];
	return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	if (searchBar.text.length > 0)
		return YES;
	return NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	
	[SVProgressHUD showWithStatus:@"Searching..."];
	
    [searchBar resignFirstResponder];
	
    [_rdio callAPIMethod:@"search" withParameters:@{@"query":searchBar.text,
                                                    @"types":@"Track"}
                 success:^(NSDictionary *result) {
                     NSMutableArray * tempMutableArray = [NSMutableArray new];
                     tempMutableArray = [result objectForKey:@"results"];
                     _trackArray = [NSMutableArray new];
                     for (NSDictionary * trackObject in tempMutableArray) {
                         RdioTrack * track = [[RdioTrack alloc] initWithDict:trackObject];
                         [_trackArray addObject:track];
//                         NSLog(@"TRACK NAME: %@",track.trackName);
                     }
                     [_trackTableView reloadData];
					 
					 [SVProgressHUD dismiss];
					 
                 } failure:^(NSError *error) {
                     
                 }];

}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self searchBarTextDidEndEditing:searchBar];
}

/*
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	// Fast search
}
 */

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:^{ }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
