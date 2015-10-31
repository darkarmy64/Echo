//
//  SearchTableViewCell.m
//  DUCEPRO
//
//  Created by Avikant Saini on 10/31/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "SearchTableViewCell.h"

#define WIDTH self.bounds.size.width
#define HEIGHT self.bounds.size.height

@implementation SearchTableViewCell

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
	CGContextSetLineWidth(context, 0.5);
	CGContextMoveToPoint(context, self.trackNameLabel.frame.origin.x, HEIGHT);
	CGContextAddLineToPoint(context, WIDTH, HEIGHT);
	CGContextSetShadow(context, CGSizeZero, 3.f);
	CGContextDrawPath(context, kCGPathStroke);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
