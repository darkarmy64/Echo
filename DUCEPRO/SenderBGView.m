//
//  SenderBGView.m
//  DUCEPRO
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "SenderBGView.h"

@implementation SenderBGView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[[UIColor darkGrayColor] setStroke];
	[path moveToPoint:CGPointZero];
	[path setLineWidth:1.5f];
	[path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
	[path stroke];
}

@end
