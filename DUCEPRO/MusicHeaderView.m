//
//  MusicHeaderView.m
//  Player View Demo
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 Dark Army. All rights reserved.
//

#import "MusicHeaderView.h"

#define WIDTH self.bounds.size.width
#define HEIGHT self.bounds.size.height

@implementation MusicHeaderView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.



- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = CGRectMake(0, self.songNameLabel.frame.origin.y - 20, WIDTH, HEIGHT - self.songNameLabel.frame.origin.y + 20);
	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
	[self.layer insertSublayer:gradient atIndex:1];
	
}

-(void)layoutSubviews {
	self.playPauseButton.tintColor = [UIColor whiteColor];
}

-(void)setPlaying:(BOOL)playing {
	[UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.playPauseButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		if (playing) {
			self.playState = PlayStatePlaying;
			[self.playPauseButton setPaused:NO animated:YES];
		}
		else {
			self.playState = PlayStatePaused;
			[self.playPauseButton setPaused:YES animated:YES];
		}
		[UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
			self.playPauseButton.alpha = 0.1;
		} completion:^(BOOL finished) {
			
		}];
	}];
//	if (playing) {
//		self.playState = PlayStatePlaying;
//		[self.playPauseButton setPaused:NO animated:YES];
//	}
//	else {
//		self.playState = PlayStatePaused;
//		[self.playPauseButton setPaused:YES animated:YES];
//	}
}


@end
