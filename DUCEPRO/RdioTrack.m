//
//  RdioTrack.m
//  DUCEPRO
//
//  Created by Shubham Sorte on 29/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "RdioTrack.h"

@implementation RdioTrack

-(id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if(self) {
        self.trackName = [dict objectForKey:@"name"];
        self.trackAlbum = [dict objectForKey:@"album"];
        self.trackIcon = [dict objectForKey:@"icon400"];
        self.trackKey = [dict objectForKey:@"key"];
        self.trackArtist = [dict objectForKey:@"artist"];
    }
    return self;
}


@end
