//
//  CurvedTextField.m
//  Data Usage
//
//  Created by Avikant Saini on 10/29/15.
//  Copyright © 2015 Dark Army. All rights reserved.
//

#import "CurvedTextField.h"
#import "AppDelegate.h"

#define WIDTH self.bounds.size.width
#define HEIGHT self.bounds.size.height - 1

@implementation CurvedTextField

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CGPoint leftL = CGPointMake(2, HEIGHT - self.curveRadius);
	CGPoint rightR = CGPointMake(WIDTH - 2, HEIGHT - self.curveRadius);
	
	CGPoint bottomL = CGPointMake(self.curveRadius + 2, HEIGHT);
	CGPoint bottomR = CGPointMake(WIDTH - self.curveRadius - 2, HEIGHT);
	
	CGPoint lineL = CGPointMake(bottomL.x + 10, bottomL.y);
	CGPoint lineR = CGPointMake(bottomR.x - 10, bottomR.y);
	
	[GLOBAL_TINT_COLOR setStroke];
	
	UIBezierPath *curvePath = [UIBezierPath bezierPath];
	[curvePath setLineWidth:0.5f];
	[curvePath moveToPoint:leftL];
	[curvePath addQuadCurveToPoint:lineL controlPoint:bottomL];
	[curvePath moveToPoint:lineL];
	[curvePath addLineToPoint:lineR];
	[curvePath addQuadCurveToPoint:rightR controlPoint:bottomR];
	[curvePath moveToPoint:rightR];
	[curvePath stroke];
	
	UIBezierPath *linePath = [UIBezierPath bezierPath];
	[linePath setLineWidth:1.5f];
	[linePath moveToPoint:lineL];
	[linePath addLineToPoint:lineR];
	[linePath closePath];
	
	self.layer.shadowColor = GLOBAL_TINT_COLOR.CGColor;
	self.layer.shadowOpacity = 1.f;
	self.layer.shadowOffset = CGSizeMake(0.f, 1.f);
	self.layer.shadowRadius = 1.f;
	self.layer.masksToBounds = NO;
	self.layer.shadowPath = linePath.CGPath;
	
}

@end
