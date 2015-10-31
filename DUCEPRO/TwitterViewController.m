//
//  TwitterViewController.m
//  DUCEPRO
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// TODO: Base this Tweet ID on some data from elsewhere in your app
	
	if (!self.searchString)
		self.searchString = @"#music";
	
	TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
	
	TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:self.searchString APIClient:client];
	
	self.dataSource = dataSource;
	
	[TWTRTweetView appearance].theme = TWTRTweetViewThemeDark;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
