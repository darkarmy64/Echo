//
//  MusicHeaderView.h
//  Player View Demo
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 Dark Army. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSPlayPauseButton.h"

typedef NS_ENUM(NSUInteger, PlayState) {
	PlayStatePlaying,
	PlayStatePaused,
};

@interface MusicHeaderView : UIView

@property PlayState playState;

-(void)setPlaying:(BOOL)playing;

@property (weak, nonatomic) IBOutlet RSPlayPauseButton *playPauseButton;

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumLabel;

@property (weak, nonatomic) IBOutlet UIImageView *albumCoverImageView;

@property (strong, nonatomic) IBOutlet UIButton *twitterButton;


@end
