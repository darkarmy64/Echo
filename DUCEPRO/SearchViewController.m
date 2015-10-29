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

@interface SearchViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RdioDelegate>
{
     Rdio *_rdio;
}
@property NSMutableArray * trackArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rdio = [AppDelegate sharedRdio];
    [_rdio setDelegate:self];
}

- (void)cancelSearch {
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UISearchBar *searchBar = _trackSearchBar;
//    CGRect rect = searchBar.frame;
//    rect.origin.y = MIN(0, scrollView.contentOffset.y);
//    searchBar.frame = rect;
//}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trackArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    RdioTrack * track = [_trackArray objectAtIndex:indexPath.row];
    cell.textLabel.text = track.trackName;
    cell.detailTextLabel.text = track.trackAlbum;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:track.trackIcon] placeholderImage:[UIImage imageNamed:@"tux_duce.png"]];
     
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RdioTrack * track = [_trackArray objectAtIndex:indexPath.row];
    [self.delegate receiveMessage:track];

//    [[NSUserDefaults standardUserDefaults] setObject:[_trackArray objectAtIndex:indexPath.row] forKey:@"CURRENT_TRACK"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * blankView = [[UIView alloc] initWithFrame:CGRectZero];
    return blankView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    _trackSearchBar = [[UISearchBar alloc] init];
    [_trackSearchBar sizeToFit];
    [_trackSearchBar setDelegate:self];
    return _trackSearchBar;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
#pragma mark Search Bar Delegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
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
                         NSLog(@"TRACK NAME: %@",track.trackName);
                     }
                     [_trackTableView reloadData];
                 } failure:^(NSError *error) {
                     
                 }];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // You can write search code Here
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
