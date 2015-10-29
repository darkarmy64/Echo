//
//  ViewController.h
//  DUCEPRO
//
//  Created by Shubham Sorte on 28/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

@interface ViewController : UIViewController <RdioDelegate, RDPlayerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;

- (IBAction)loginTapped:(id)sender;
- (IBAction)playPauseTapped:(id)sender;

@end

